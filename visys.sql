-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-12-2016 a las 17:09:41
-- Versión del servidor: 10.1.13-MariaDB
-- Versión de PHP: 5.6.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `visys`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_Catalogo` (IN `CATALOGO` INT)  BEGIN
		DECLARE v_IdCT, v_CodImg, v_Puntos 	INT;
		DECLARE v_Nombre VARCHAR(255);
		DECLARE v_Imagen VARCHAR(150);
		
		DECLARE cont, conse INT DEFAULT 1;
		
		DECLARE CSQL TEXT DEFAULT "(";
		DECLARE RELLENO, errores INT DEFAULT 0;
		
		DECLARE data_cursor CURSOR FOR 
			SELECT detallect.IdCT, detallect.IdIMG, detallect.Nombre, detallect.IMG, detallect.Puntos
			FROM detallect
			WHERE detallect.IdCT = CATALOGO AND detallect.Estado <> 1
			ORDER BY detallect.IdIMG;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET errores = 1;

		SELECT COUNT(IdCT) INTO RELLENO FROM detallect WHERE detallect.IdCT = CATALOGO AND detallect.Estado <> 1;
       
        IF RELLENO <> 0 THEN
          OPEN data_cursor;
               read_data: LOOP
                          FETCH data_cursor INTO v_IdCT, v_CodImg, v_Nombre, v_Imagen, v_Puntos;
				
				           IF errores = 1 THEN LEAVE read_data; END IF;
                
				           SET CSQL = CONCAT(CSQL, v_IdCT, ",", v_CodImg, ",'", v_Nombre, "','", v_Imagen, "',", v_Puntos);
                
				           IF cont = 4 THEN                    
                              IF conse = RELLENO THEN
                                 SET CSQL = CONCAT(CSQL, ")");
                              ELSE
                                  SET CSQL = CONCAT(CSQL, "),(");
                              END IF;	
                    
                              SET cont = 0;
                          ELSEIF conse < RELLENO THEN
                              SET CSQL = CONCAT(CSQL, ",");   
                          END IF;
				
				          SET cont = cont + 1;
				          SET conse = conse + 1;
                END LOOP read_data;
		    CLOSE data_cursor;
            	    
		    SET RELLENO = 4 - (((RELLENO/4) - FLOOR(RELLENO/4)) * 4);
		    
		    IF RELLENO < 4 THEN
               SET CSQL = CONCAT(CSQL, ",");
               
			   WHILE RELLENO <> 0 DO
			         SET CSQL = CONCAT(CSQL, "'0','0','','','0'");
            		 SET RELLENO = RELLENO - 1;
                
				     IF RELLENO <> 0 THEN
				        SET CSQL = CONCAT(CSQL, ",");
                     ELSE
                        SET CSQL = CONCAT(CSQL, ")");
                     END IF;
               END WHILE;
           END IF;
   	       
		   DELETE FROM tmp_Catalogo;
           
		   SET @query = CONCAT("INSERT INTO tmp_Catalogo VALUES", CSQL);
           
		   PREPARE IC FROM @query; 
		   EXECUTE IC; 
		   DEALLOCATE PREPARE IC;
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_Clientes_Facturas` (IN `cod` VARCHAR(20))  BEGIN
				SELECT GROUP_CONCAT(CONCAT("'",Factura,"'")) as Facturas  
				FROM view_frp_factura
				WHERE IdCliente = cod AND SALDO = 0 AND ANULADO = 'N'
				GROUP BY IdCliente;					
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_Clientes_Facturas_Fre` (IN `cod` CHAR(20))  BEGIN
								SELECT GROUP_CONCAT(CONCAT("'",Factura,"'")) as Facturas  
								FROM view_fre_factura
								WHERE IdCliente = cod
								AND Anulado='N'
								GROUP BY IdCliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_clientes_pa` (IN `CODIGO` INT)  BEGIN
SELECT T0.IdCliente, SUM(T0.Puntos) AS Puntos FROM view_frp_factura T0
  WHERE T0.Anulado = 'N' AND T0.IdCliente = CODIGO
  GROUP BY T0.IdCliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_clientes_pe` (IN `cod` CHAR(20))  BEGIN
                SELECT T0.IdCliente, SUM(T0.Puntos) AS Puntos FROM view_fre_factura T0
								WHERE T0.Anulado = 'N' AND T0.IdCliente = cod
								GROUP BY T0.IdCliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_MFactura` (IN `infactura` CHAR(20), IN `inpuntos` INT, IN `fecha` DATETIME)  BEGIN
             UPDATE rfactura SET Puntos = (Puntos + INPUNTOS), FechaActualizacion = FECHA  WHERE Factura = INFACTURA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pc_RFactura` (IN `INFACTURA` CHAR(20), IN `INPUNTOS` INT, IN `CLIENTE` CHAR(30), IN `FECHA` DATETIME, IN `ttpuntos` INT)  BEGIN
                IF EXISTS(SELECT Factura FROM rfactura  WHERE Factura=INFACTURA) THEN
                BEGIN
                    UPDATE rfactura SET Puntos= (Puntos - INPUNTOS), FechaActualizacion = FECHA  WHERE Factura = INFACTURA;
                END;
                ELSE
                BEGIN
                               INSERT INTO rfactura (IdCliente,Factura,ttPuntos,Puntos,FechaActualizacion) 
                               VALUES(CLIENTE,INFACTURA,ttpuntos,ttpuntos-INPUNTOS,FECHA);       
               END;
END IF ;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogo`
--

CREATE TABLE `catalogo` (
  `IdCT` int(11) NOT NULL,
  `Descripcion` varchar(150) DEFAULT NULL,
  `Estado` bit(1) DEFAULT NULL,
  `Fecha` date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `catalogo`
--

INSERT INTO `catalogo` (`IdCT`, `Descripcion`, `Estado`, `Fecha`) VALUES
(3, 'Agosto', b'1', '2016-08-01'),
(8, 'CATALOGO DE SEPTIEMBRE', b'0', '2016-09-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallect`
--

CREATE TABLE `detallect` (
  `IdCT` int(11) DEFAULT NULL COMMENT 'Id de Imagén',
  `IdIMG` varchar(15) DEFAULT NULL,
  `Nombre` varchar(255) DEFAULT NULL,
  `IMG` varchar(150) DEFAULT NULL COMMENT 'nombre de la imagén',
  `Puntos` int(20) DEFAULT NULL,
  `Estado` bit(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `detallect`
--

INSERT INTO `detallect` (`IdCT`, `IdIMG`, `Nombre`, `IMG`, `Puntos`, `Estado`) VALUES
(8, '142489', 'A/C SPLIT FRIGID FASX12F2MBHLW INVERTER', '142489.jpg', 29969, b'0'),
(8, '125686', 'ABAN BOX LASKO 3300', '125686.jpg', 3035, b'0'),
(8, '127065', 'ABAN MESA AERO SPEED AC800 8"', '127065.jpg', 1432, b'0'),
(8, '112991', 'ABAN PIE LASKO 1824 18"', '112991.jpg', 1698, b'0'),
(8, '112989', 'ABAN PIE LASKO 1827 18"', '112989.jpg', 2877, b'0'),
(8, '112990', 'ABAN PIE LASKO 1850 18"', '112990.jpg', 3886, b'0'),
(8, '111066', 'ABAN PIE LASKO 2526 16"', '111066.jpg', 2722, b'0'),
(8, '145499', 'ABAN PIE SANKEY FN1746 16"', '145499.jpg', 2423, b'0'),
(8, '131385', 'ABAN PIE SANKEY FN17A02B 16"', '131385.jpg', 1971, b'0'),
(8, '112986', 'ABAN TORRE LASKO 2510 36"', '112986.jpg', 4514, b'0'),
(8, '133898', 'ABAN TORRE LASKO 2519 36"', '133898.jpg', 4718, b'0'),
(8, '149049', 'ABAN TORRE LASKO 2535 52"', '149049.jpg', 4984, b'0'),
(8, '149990', 'CAFETERA HBEACH 43253R 12TZ', '149990.jpg', 3567, b'0'),
(8, '139245', 'CAFETERA B&D BCM1410B 12TZ NEG', '139245.jpg', 2010, b'0'),
(8, '149989', 'CAFETERA HBEACH 46201 12TZ', '149989.jpg', 3849, b'0'),
(8, '148338', 'CENTRO ENTRET FAMESA BROOKLYN', '148338.jpg', 10188, b'0'),
(8, '148402', 'CENTRO ENTRET FAMESA MANHATHAN', '148402.jpg', 12340, b'0'),
(8, '148397', 'CENTRO ENTRET FAMESA MEDIEVAL', '148397.jpg', 23694, b'0'),
(8, '148337', 'CENTRO ENTRET FAMESA NEW SHARI', '148337.jpg', 13434, b'0'),
(8, '139561', 'CENTRO ENTRET FAMESA TIKAL', '139561.jpg', 13705, b'0'),
(8, '137056', 'COC GAS ATLAS EAG2006BIB1 20" 4Q BLC', '137056.jpg', 9936, b'0'),
(8, '142599', 'COC GAS FRIGID FKGD20C3NNG 20" 4Q PLT', '142599.jpg', 12149, b'0'),
(8, '149629', 'COC GAS FRIGID FKGM30C3BBPG 30" 5Q GRIS', '149629.jpg', 17884, b'0'),
(8, '142597', 'COC GAS FRIGID FKGD30J3NNG 30" 6Q PLT', '142597.jpg', 18967, b'0'),
(8, '146637', 'COC GAS MABE EM5132BI01 20" 4Q BLC', '146637.jpg', 10979, b'0'),
(8, '143131', 'COC GAS GE EG3092CX2 30" 6Q INOX', '143131.jpg', 34464, b'0'),
(8, '151795', 'COC GAS MABE EM7671CFIX0 30" 6Q INOX', '151795.jpg', 24998, b'0'),
(8, '152089', 'COMP PORT LENOVO N22 N3050 4GB32GB 11.6"', '152089.jpg', 14304, b'0'),
(8, '147899', 'COMP PORT HP 14AC111LA CI3 1TB 14" W10', '147899.jpg', 33472, b'0'),
(8, '152005', 'COMP PORT LENOVO B4080 14" I3 500GB W10', '152005.jpg', 27998, b'0'),
(8, '148510', 'CONG HTL FRIGID FFC09A3MPW 9CF BLC', '148510.jpg', 16635, b'0'),
(8, '148511', 'CONG HTL FRIGID FFC15A3MNW 15CF BLC', '148511.jpg', 24918, b'0'),
(8, '148139', 'CONG HTL FRIGID FFC18A3MNW 18CF BLC', '148139.jpg', 33293, b'0'),
(8, '144396', 'CONG HTL FRIGID FFFC22M6QW 22CF BLC', '144396.jpg', 43294, b'0'),
(8, '149695', 'CONG HTL LG GC34BPW 12CF INOX', '149695.jpg', 20503, b'0'),
(8, '136783', 'DVD LG DP132 2.1CH DIVX', '136783.jpg', 2598, b'0'),
(8, '134857', 'DVD SONY DVPSR370 USB', '134857.jpg', 2754, b'0'),
(8, '149085', 'EXTRACTOR HBEACH 67801', '149085.jpg', 1892, b'0'),
(8, '124498', 'HORNO MIC LG MS1140S 1.1CF GR', '124498.jpg', 5921, b'0'),
(8, '135383', 'HORNO MIC LG MS1142GW 1.1CF BLC', '135383.jpg', 5170, b'0'),
(8, '131237', 'HORNO MIC SAMSUNG AMW831K 0.8CF BLC', '131237.jpg', 4498, b'0'),
(8, '135742', 'HORNO MIC TELSTAR TMD2015DQ 0.7CF BLC', '135742.jpg', 3598, b'0'),
(8, '107192', 'HORNO MIC WHIRLP WM1111D 1.1CF GR', '107192.jpg', 5729, b'0'),
(8, '129466', 'HORNO MIC WHIRLP WMP07ZDTS 0.7CF SILVER', '129466.jpg', 4735, b'0'),
(8, '139249', 'HORNO TOST B&D CTO6335S', '139249.jpg', 7035, b'0'),
(8, '142470', 'HORNO TOST B&D TO1303RB', '142470.jpg', 2686, b'0'),
(8, '126858', 'HORNO TOST B&D TO1420B', '126858.jpg', 1798, b'0'),
(8, '120344', 'HORNO TOST B&D TRO420', '120344.jpg', 2083, b'0'),
(8, '149995', 'HORNO TOST HBEACH 22722', '149995.jpg', 2883, b'0'),
(8, '141399', 'JGO COMEDOR PREMIUM ITALIA 4 S', '141399.jpg', 13851, b'0'),
(8, '150344', 'JGO COMEDOR PRIMIUN MADRID 4 S', '150344.jpg', 14358, b'0'),
(8, '139751', 'JGO COMEDOR PRIMIUN TEVEZ 6 S', '139751.jpg', 18526, b'0'),
(8, '146153', 'JGO COMEDOR TRISWIFT FRANKLIN 4 S', '146153.jpg', 7867, b'0'),
(8, '150494', 'JGO SALA CAPRI DELUXE ESQUINERA 22', '150494.jpg', 23292, b'0'),
(8, '150493', 'JGO SALA CAPRI NOVA MODULAR 32', '150493.jpg', 25494, b'0'),
(8, '105233', 'JGO SALA CAPRI SINAI', '105233.jpg', 19616, b'0'),
(8, '149887', 'JGO SALA CAPRI SINAI AZ', '149887.jpg', 19998, b'0'),
(8, '149890', 'JGO SALA CAPRI SINAI CAF', '149890.jpg', 19998, b'0'),
(8, '149888', 'JGO SALA CAPRI SINAI VERD', '149888.jpg', 19998, b'0'),
(8, '149065', 'JGO SALA DULER BALI 32 CAF', '149065.jpg', 28210, b'0'),
(8, '149066', 'JGO SALA DULER BALI 32 ROJ', '149066.jpg', 28485, b'0'),
(8, '149058', 'JGO SALA DULER COLIMA 32 CAF', '149058.jpg', 25960, b'0'),
(8, '149059', 'JGO SALA DULER COLIMA 32 TERRACOTA', '149059.jpg', 25773, b'0'),
(8, '149064', 'JGO SALA DULER MONTREAL TERRACOTA', '149064.jpg', 47753, b'0'),
(8, '149060', 'JGO SALA DULER WYN ESQ TERRACOTA', '149060.jpg', 37213, b'0'),
(8, '149061', 'JGO SALA DULER WYN ESQ TURQ', '149061.jpg', 36682, b'0'),
(8, '144930', 'JGO SALA MAXISALAS MODULAR PALERMO', '144930.jpg', 30228, b'0'),
(8, '138883', 'JGO SALA MAXISALAS TORONTO 321', '138883.jpg', 41178, b'0'),
(8, '150894', 'JGO SALA MERJEN BOREAL CAF OSCURO', '150894.jpg', 22518, b'0'),
(8, '150890', 'JGO SALA MERJEN BOREAL ROJ', '150890.jpg', 22797, b'0'),
(8, '150893', 'JGO SALA MERJEN BOREAL TURQ', '150893.jpg', 22710, b'0'),
(8, '150888', 'JGO SALA MERJEN MALAGA ESQUINERO', '150888.jpg', 24530, b'0'),
(8, '105975', 'JGO SALA TRAVERS EMPERADOR', '105975.jpg', 25744, b'0'),
(8, '149343', 'JGO SALA VASQUEZ URBAN BEIGE', '149343.jpg', 19943, b'0'),
(8, '146568', 'LAV AUTO FRIGID FWAC19H4MSMNW 19KG BLC', '146568.jpg', 27787, b'0'),
(8, '145573', 'LAV AUTO FRIGID FWIL20F3MNW 20KG BLC', '145573.jpg', 24542, b'0'),
(8, '114045', 'LAV AUTO FRIGID FWLI126FBGWT 12KG BLC', '114045.jpg', 16693, b'0'),
(8, '134445', 'LAV AUTO LG WFS1634EK 16KG SILVER', '134445.jpg', 24167, b'0'),
(8, '135758', 'LAV AUTO FRIGID FWLI13B3MSLG 13KG GR', '135758.jpg', 19121, b'0'),
(8, '151800', 'LAV AUTO MABE LMA77113CBAB0 17KG BLC', '151800.jpg', 22305, b'0'),
(8, '150637', 'LAV AUTO WHIRLP 7MWTW1500EM 15KG BLC', '150637.jpg', 25505, b'0'),
(8, '135470', 'LAV SEMI ATLAS LAD1400CB 14KG BLC', '135470.jpg', 10240, b'0'),
(8, '147478', 'LAV SEMI TELSTAR TLS13050CF 13KG BLC', '147478.jpg', 8714, b'0'),
(8, '139335', 'LAV SEMI TELSTAR TLS18050CF 18KG BLC', '139335.jpg', 11374, b'0'),
(8, '142471', 'LICUADORA B&D BL1110RG VID 12 V', '142471.jpg', 2609, b'0'),
(8, '140064', 'LICUADORA B&D BL1130SGM VID 12 V', '140064.jpg', 2870, b'0'),
(8, '149084', 'LICUADORA HBEACH 58148 VID 4 V', '149084.jpg', 2033, b'0'),
(8, '145186', 'MINICOMP LG CM4350 3000W', '145186.jpg', 9998, b'0'),
(8, '149532', 'MINICOMP LG CM4360 2500W', '149532.jpg', 9183, b'0'),
(8, '149862', 'MINICOMP LG CM4460 5300W', '149862.jpg', 11916, b'0'),
(8, '149863', 'MINICOMP LG CM4560 8000W', '149863.jpg', 15238, b'0'),
(8, '149866', 'MINICOMP LG CM5760 13200W', '149866.jpg', 17871, b'0'),
(8, '149864', 'MINICOMP LG CM8460 32000W', '149864.jpg', 29531, b'0'),
(8, '150116', 'MINICOMP LG CM9960 52800W', '150116.jpg', 64599, b'0'),
(8, '140062', 'MINIPROCESADOR B&D FP2500B', '140062.jpg', 3543, b'0'),
(8, '148948', 'MULTIFUNCIONAL INYEC HP UIA4535', '148948.jpg', 4958, b'0'),
(8, '151325', 'OLLA ARROC B&D RC5200M INOX 20TZ', '151325.jpg', 2329, b'0'),
(8, '148350', 'OLLA ARROC B&D RC5280 30TZ', '148350.jpg', 2904, b'0'),
(8, '106042', 'OLLA ARROC B&D RC860 10TZ', '106042.jpg', 2917, b'0'),
(8, '127450', 'OLLA ARROC HBEACH 37538 12TZ ROJ', '127450.jpg', 1760, b'0'),
(8, '104089', 'OLLA ARROC OSTER 4730 12TZ', '104089.jpg', 2785, b'0'),
(8, '131193', 'OLLA PRES TELSTAR TPS1300NR 13L', '131193.jpg', 1851, b'0'),
(8, '149088', 'PARRILLA ELEC HBEACH 38546', '149088.jpg', 3569, b'0'),
(8, '146981', 'PERCOLADOR HBEACH 40516 42TZ', '146981.jpg', 3191, b'0'),
(8, '125106', 'PLANCHA OSTER GCSTBS5803 VAPOR', '125106.jpg', 1051, b'0'),
(8, '150022', 'PLANCHA B&D IR1820 VAPOR', '150022.jpg', 1161, b'0'),
(8, '131194', 'PLANT GAS TELSTAR TPG0255YK 2Q INOX', '131194.jpg', 1399, b'0'),
(8, '131195', 'PLANT GAS TELSTAR TPG0355YK 3Q INOX', '131195.jpg', 1508, b'0'),
(8, '146899', 'RADIOGRAB SONY ZSPS50 MP3', '146899.jpg', 5598, b'0'),
(8, '142922', 'REF AUTO ATLAS RTA1025VCAB0 10CF275L BLC', '142922.jpg', 19965, b'0'),
(8, '146346', 'REF AUTO FRIGID FRT40K3MPS 14CF405L INOX', '146346.jpg', 28749, b'0'),
(8, '142376', 'REF AUTO LG GT32BPP 12CF 330L SILVER', '142376.jpg', 29988, b'0'),
(8, '146149', 'REF AUTO LG GT29BPP 9CF 272L INOX', '146149.jpg', 23990, b'0'),
(8, '131776', 'REF AUTO MABE RME1436YMX 14CF 380L GRAF', '131776.jpg', 29552, b'0'),
(8, '150255', 'REF SEMI CETRON RCC300WNS 11CF 325L GRAF', '150255.jpg', 15669, b'0'),
(8, '144399', 'REF SEMI FRIGID FRT13G3HNW 6CF 168L BLC', '144399.jpg', 12958, b'0'),
(8, '140175', 'REF SEMI TELSTAR TRS09510MD 4CF 95L BLC', '140175.jpg', 8478, b'0'),
(8, '140174', 'REF SEMI TELSTAR TRS14005MD 5CF 140L SIL', '140174.jpg', 8495, b'0'),
(8, '146044', 'REF SXS FRIGID FFSS2614QS 26CF 736L INOX', '146044.jpg', 73998, b'0'),
(8, '139831', 'REF SXS GE PSMS6FGFFSS 26CF 736L INOX', '139831.jpg', 77105, b'0'),
(8, '148044', 'ROPERO FAMESA OCRE COLONIAL WENGUE', '148044.jpg', 24481, b'0'),
(8, '117212', 'ROPERO FAMESA MADRID CAOBA 4PTAS', '117212.jpg', 22044, b'0'),
(8, '129209', 'SART ELEC TELSTAR TSE3030FH 12"', '129209.jpg', 1450, b'0'),
(8, '134670', 'SET COL CAPRI REST MASTER 3EN1 QUEEN 160', '134670.jpg', 18668, b'0'),
(8, '118659', 'SET COL CAPRI REST MASTER ORTHO QUEEN 16', '118659.jpg', 18239, b'0'),
(8, '146146', 'TABLET HUAWEI MEDIA PAD T1 7" 8GB 3G', '146146.jpg', 7870, b'0'),
(8, '137547', 'TABLET SANKEY TAB1011 10.1" DC 8GB', '137547.jpg', 5060, b'0'),
(8, '146974', 'TEATRO EN CASA C/DVD LG LHD625', '146974.jpg', 15108, b'0'),
(8, '149750', 'TV LED 20" TELSTAR TTL020230KK ISDBT', '149750.jpg', 7378, b'0'),
(8, '148155', 'TV LED 24" TELSTAR TTL024430KK ISDBT', '148155.jpg', 9479, b'0'),
(8, '149626', 'TV LED 28" TELSTAR TTL028430KK ISDBT', '149626.jpg', 10798, b'0'),
(8, '150046', 'TV LED 43" TELSTAR TTL043430KK ISDBT', '150046.jpg', 21596, b'0'),
(8, '151168', 'TV LED 24" LG 24MT48', '151168.jpg', 10598, b'0'),
(8, '150134', 'TV LED 32" LG 32LH510B', '150134.jpg', 16598, b'0'),
(8, '150140', 'TV LED 43" LG 43LH5100', '150140.jpg', 25006, b'0'),
(8, '150029', 'TV LED 48" SONY KDL48W655D LA8 SMART', '150029.jpg', 49085, b'0'),
(8, '135360', 'TV LED 32" SONY KDL32W605 LA8 SMART', '135360.jpg', 24065, b'0'),
(8, '145384', 'TEL CEL 3G LG Y30 JOY', '145384.jpg', 6992, b'0'),
(8, '151091', 'TEL CEL 3G HUAWEI Y5 II', '151091.jpg', 8481, b'0'),
(8, '145175', 'TEL CEL 3G HUAWEI Y520', '145175.jpg', 6778, b'0'),
(8, '150381', 'TEL CEL 3G SAMSUNG GALAXY J1 MINI', '150381.jpg', 7198, b'0'),
(8, '150380', 'TEL CEL 4G HUAWEI GR5', '150380.jpg', 24426, b'0'),
(8, '148419', 'TEL CEL 4G SAMSUNG GALAXY A3 2016', '148419.jpg', 25903, b'0'),
(8, '151376', 'TEL CEL 4G SAMSUNG GALAXY J1 2016', '151376.jpg', 11645, b'0'),
(8, '148781', 'TEL CEL 4G SAMSUNG GALAXY J2 LTE', '148781.jpg', 12468, b'0'),
(8, '149891', 'TEL CEL 4G SAMSUNG GALAXY J3', '149891.jpg', 14782, b'0'),
(8, '148110', 'TEL CEL 4G SAMSUNG GALAXY J5 LTE', '148110.jpg', 17015, b'0'),
(8, '148111', 'TEL CEL 4G SAMSUNG GALAXY J7 LTE', '148111.jpg', 22020, b'0'),
(8, '150672', 'MOTO SERPENTO BOA 150CC NEG 2017', '150672.jpg', 66352, b'0'),
(8, '150673', 'MOTO SERPENTO BOA 150CC ROJ 2017', '150673.jpg', 66208, b'0'),
(8, '146693', 'MOTO SERPENTO CLICK 150 AZ 2016', '146693.jpg', 58845, b'0'),
(8, '150548', 'MOTO SERPENTO COBRA 150 NEG 2017', '150548.jpg', 51519, b'0'),
(8, '150549', 'MOTO SERPENTO COBRA 150 ROJ 2017', '150549.jpg', 51516, b'0'),
(8, '146699', 'MOTO SERPENTO CORAL 150 NEG 2016', '146699.jpg', 48527, b'0'),
(8, '146700', 'MOTO SERPENTO CORAL 150 ROJ 2016', '146700.jpg', 49366, b'0'),
(8, '146694', 'MOTO SERPENTO DEFENDER 150 NEG 2016', '146694.jpg', 55944, b'0'),
(8, '146695', 'MOTO SERPENTO DEFENDER 150 VER 2016', '146695.jpg', 56335, b'0'),
(8, '152067', 'MOTO SERPENTO DRACO 200 NEG MATTE 2017', '152067.jpg', 80499, b'0'),
(8, '152065', 'MOTO SERPENTO DRACO 200 ROJ/NEG 2017', '152065.jpg', 80499, b'0'),
(8, '146704', 'MOTO SERPENTO NAGA 200 NEG 2016', '146704.jpg', 64807, b'0'),
(8, '146705', 'MOTO SERPENTO NAGA 200 ROJ 2016', '146705.jpg', 65422, b'0'),
(8, '146707', 'MOTO SERPENTO SPIRIT 250 BLC 2016', '146707.jpg', 120323, b'0'),
(8, '146706', 'MOTO SERPENTO SPIRIT 250 ROJ 2016', '146706.jpg', 120312, b'0'),
(8, '151069', 'MOTO SERPENTO TAYPAN 150 NEG 2017', '151069.jpg', 43178, b'0'),
(8, '150541', 'MOTO SERPENTO TAYPAN 150 ROJ 2017', '150541.jpg', 43206, b'0'),
(8, '146714', 'MOTO SERPENTO YARA S 200 AZ 2016', '146714.jpg', 69385, b'0'),
(8, '146715', 'MOTO SERPENTO YARA S200 ROJ 2016', '146715.jpg', 69450, b'0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefre`
--

CREATE TABLE `detallefre` (
  `IdFRE` varchar(11) DEFAULT NULL,
  `Factura` varchar(255) DEFAULT NULL,
  `Fecha` datetime DEFAULT NULL,
  `Puntos` int(11) DEFAULT NULL,
  `Efectivo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefrp`
--

CREATE TABLE `detallefrp` (
  `IdFRP` int(10) NOT NULL,
  `Factura` varchar(10) NOT NULL,
  `Fecha` varchar(15) NOT NULL,
  `Faplicado` int(20) NOT NULL,
  `IdArticulo` int(10) NOT NULL,
  `Descripcion` varchar(50) NOT NULL,
  `Puntos` int(20) NOT NULL,
  `Cantidad` int(10) NOT NULL,
  `IdCT` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Detalles del FRP';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `fre`
--

CREATE TABLE `fre` (
  `IdFRE` varchar(11) NOT NULL,
  `Fecha` datetime DEFAULT NULL,
  `IdCliente` varchar(255) DEFAULT NULL,
  `Nombre` varchar(255) DEFAULT NULL,
  `IdUsuario` int(11) DEFAULT NULL,
  `Anulado` varchar(255) DEFAULT NULL,
  `Comentario` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `frp`
--

CREATE TABLE `frp` (
  `IdFRP` int(10) NOT NULL,
  `Fecha` datetime NOT NULL,
  `IdCliente` varchar(10) NOT NULL,
  `Nombre` varchar(50) NOT NULL,
  `IdUsuario` int(11) NOT NULL,
  `Anulado` varchar(1) NOT NULL,
  `IdCT` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `fr_total`
--
CREATE TABLE `fr_total` (
`FACTURA` varchar(255)
,`SALDO` decimal(42,0)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logcatalogo`
--

CREATE TABLE `logcatalogo` (
  `IdCL` int(11) NOT NULL,
  `Fecha` datetime DEFAULT NULL,
  `CodigoImg` int(11) DEFAULT NULL,
  `IdUsuario` int(11) DEFAULT NULL,
  `Puntos` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rfactura`
--

CREATE TABLE `rfactura` (
  `IdCliente` varchar(20) NOT NULL,
  `Factura` varchar(20) NOT NULL,
  `ttPuntos` int(100) NOT NULL,
  `Puntos` int(20) NOT NULL,
  `FechaActualizacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `IdRol` int(10) NOT NULL COMMENT 'Id de Rol',
  `Descripcion` varchar(250) NOT NULL COMMENT 'Descripcion del Rol'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`IdRol`, `Descripcion`) VALUES
(1, 'SuperAdministrador'),
(2, 'Administrador'),
(3, 'Vendedor'),
(4, 'SAC'),
(8, 'Cartera'),
(7, 'Cliente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tmp_catalogo`
--

CREATE TABLE `tmp_catalogo` (
  `v_IdCT1` int(11) DEFAULT NULL,
  `v_IdIMG1` int(11) DEFAULT NULL,
  `v_Nombre1` varchar(255) DEFAULT NULL,
  `v_IMG1` varchar(150) DEFAULT NULL,
  `v_Puntos1` int(11) DEFAULT NULL,
  `v_IdCT2` int(11) DEFAULT NULL,
  `v_IdIMG2` int(11) DEFAULT NULL,
  `v_Nombre2` varchar(255) DEFAULT NULL,
  `v_IMG2` varchar(150) DEFAULT NULL,
  `v_Puntos2` int(11) DEFAULT NULL,
  `v_IdCT3` int(11) DEFAULT NULL,
  `v_IdIMG3` int(11) DEFAULT NULL,
  `v_Nombre3` varchar(255) DEFAULT NULL,
  `v_IMG3` varchar(150) DEFAULT NULL,
  `v_Puntos3` int(11) DEFAULT NULL,
  `v_IdCT4` varchar(255) DEFAULT NULL,
  `v_IdIMG4` int(11) DEFAULT NULL,
  `v_Nombre4` varchar(255) DEFAULT NULL,
  `v_IMG4` varchar(150) DEFAULT NULL,
  `v_Puntos4` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tmp_catalogo`
--

INSERT INTO `tmp_catalogo` (`v_IdCT1`, `v_IdIMG1`, `v_Nombre1`, `v_IMG1`, `v_Puntos1`, `v_IdCT2`, `v_IdIMG2`, `v_Nombre2`, `v_IMG2`, `v_Puntos2`, `v_IdCT3`, `v_IdIMG3`, `v_Nombre3`, `v_IMG3`, `v_Puntos3`, `v_IdCT4`, `v_IdIMG4`, `v_Nombre4`, `v_IMG4`, `v_Puntos4`) VALUES
(8, 104089, 'OLLA ARROC OSTER 4730 12TZ', '104089.jpg', 2785, 8, 105233, 'JGO SALA CAPRI SINAI', '105233.jpg', 19616, 8, 105975, 'JGO SALA TRAVERS EMPERADOR', '105975.jpg', 25744, '8', 106042, 'OLLA ARROC B&D RC860 10TZ', '106042.jpg', 2917),
(8, 107192, 'HORNO MIC WHIRLP WM1111D 1.1CF GR', '107192.jpg', 5729, 8, 111066, 'ABAN PIE LASKO 2526 16"', '111066.jpg', 2722, 8, 112986, 'ABAN TORRE LASKO 2510 36"', '112986.jpg', 4514, '8', 112989, 'ABAN PIE LASKO 1827 18"', '112989.jpg', 2877),
(8, 112990, 'ABAN PIE LASKO 1850 18"', '112990.jpg', 3886, 8, 112991, 'ABAN PIE LASKO 1824 18"', '112991.jpg', 1698, 8, 114045, 'LAV AUTO FRIGID FWLI126FBGWT 12KG BLC', '114045.jpg', 16693, '8', 117212, 'ROPERO FAMESA MADRID CAOBA 4PTAS', '117212.jpg', 22044),
(8, 118659, 'SET COL CAPRI REST MASTER ORTHO QUEEN 16', '118659.jpg', 18239, 8, 120344, 'HORNO TOST B&D TRO420', '120344.jpg', 2083, 8, 124498, 'HORNO MIC LG MS1140S 1.1CF GR', '124498.jpg', 5921, '8', 125106, 'PLANCHA OSTER GCSTBS5803 VAPOR', '125106.jpg', 1051),
(8, 125686, 'ABAN BOX LASKO 3300', '125686.jpg', 3035, 8, 126858, 'HORNO TOST B&D TO1420B', '126858.jpg', 1798, 8, 127065, 'ABAN MESA AERO SPEED AC800 8"', '127065.jpg', 1432, '8', 127450, 'OLLA ARROC HBEACH 37538 12TZ ROJ', '127450.jpg', 1760),
(8, 129209, 'SART ELEC TELSTAR TSE3030FH 12"', '129209.jpg', 1450, 8, 129466, 'HORNO MIC WHIRLP WMP07ZDTS 0.7CF SILVER', '129466.jpg', 4735, 8, 131193, 'OLLA PRES TELSTAR TPS1300NR 13L', '131193.jpg', 1851, '8', 131194, 'PLANT GAS TELSTAR TPG0255YK 2Q INOX', '131194.jpg', 1399),
(8, 131195, 'PLANT GAS TELSTAR TPG0355YK 3Q INOX', '131195.jpg', 1508, 8, 131237, 'HORNO MIC SAMSUNG AMW831K 0.8CF BLC', '131237.jpg', 4498, 8, 131385, 'ABAN PIE SANKEY FN17A02B 16"', '131385.jpg', 1971, '8', 131776, 'REF AUTO MABE RME1436YMX 14CF 380L GRAF', '131776.jpg', 29552),
(8, 133898, 'ABAN TORRE LASKO 2519 36"', '133898.jpg', 4718, 8, 134445, 'LAV AUTO LG WFS1634EK 16KG SILVER', '134445.jpg', 24167, 8, 134670, 'SET COL CAPRI REST MASTER 3EN1 QUEEN 160', '134670.jpg', 18668, '8', 134857, 'DVD SONY DVPSR370 USB', '134857.jpg', 2754),
(8, 135360, 'TV LED 32" SONY KDL32W605 LA8 SMART', '135360.jpg', 24065, 8, 135383, 'HORNO MIC LG MS1142GW 1.1CF BLC', '135383.jpg', 5170, 8, 135470, 'LAV SEMI ATLAS LAD1400CB 14KG BLC', '135470.jpg', 10240, '8', 135742, 'HORNO MIC TELSTAR TMD2015DQ 0.7CF BLC', '135742.jpg', 3598),
(8, 135758, 'LAV AUTO FRIGID FWLI13B3MSLG 13KG GR', '135758.jpg', 19121, 8, 136783, 'DVD LG DP132 2.1CH DIVX', '136783.jpg', 2598, 8, 137056, 'COC GAS ATLAS EAG2006BIB1 20" 4Q BLC', '137056.jpg', 9936, '8', 137547, 'TABLET SANKEY TAB1011 10.1" DC 8GB', '137547.jpg', 5060),
(8, 138883, 'JGO SALA MAXISALAS TORONTO 321', '138883.jpg', 41178, 8, 139245, 'CAFETERA B&D BCM1410B 12TZ NEG', '139245.jpg', 2010, 8, 139249, 'HORNO TOST B&D CTO6335S', '139249.jpg', 7035, '8', 139335, 'LAV SEMI TELSTAR TLS18050CF 18KG BLC', '139335.jpg', 11374),
(8, 139561, 'CENTRO ENTRET FAMESA TIKAL', '139561.jpg', 13705, 8, 139751, 'JGO COMEDOR PRIMIUN TEVEZ 6 S', '139751.jpg', 18526, 8, 139831, 'REF SXS GE PSMS6FGFFSS 26CF 736L INOX', '139831.jpg', 77105, '8', 140062, 'MINIPROCESADOR B&D FP2500B', '140062.jpg', 3543),
(8, 140064, 'LICUADORA B&D BL1130SGM VID 12 V', '140064.jpg', 2870, 8, 140174, 'REF SEMI TELSTAR TRS14005MD 5CF 140L SIL', '140174.jpg', 8495, 8, 140175, 'REF SEMI TELSTAR TRS09510MD 4CF 95L BLC', '140175.jpg', 8478, '8', 141399, 'JGO COMEDOR PREMIUM ITALIA 4 S', '141399.jpg', 13851),
(8, 142376, 'REF AUTO LG GT32BPP 12CF 330L SILVER', '142376.jpg', 29988, 8, 142470, 'HORNO TOST B&D TO1303RB', '142470.jpg', 2686, 8, 142471, 'LICUADORA B&D BL1110RG VID 12 V', '142471.jpg', 2609, '8', 142489, 'A/C SPLIT FRIGID FASX12F2MBHLW INVERTER', '142489.jpg', 29969),
(8, 142597, 'COC GAS FRIGID FKGD30J3NNG 30" 6Q PLT', '142597.jpg', 18967, 8, 142599, 'COC GAS FRIGID FKGD20C3NNG 20" 4Q PLT', '142599.jpg', 12149, 8, 142922, 'REF AUTO ATLAS RTA1025VCAB0 10CF275L BLC', '142922.jpg', 19965, '8', 143131, 'COC GAS GE EG3092CX2 30" 6Q INOX', '143131.jpg', 34464),
(8, 144396, 'CONG HTL FRIGID FFFC22M6QW 22CF BLC', '144396.jpg', 43294, 8, 144399, 'REF SEMI FRIGID FRT13G3HNW 6CF 168L BLC', '144399.jpg', 12958, 8, 144930, 'JGO SALA MAXISALAS MODULAR PALERMO', '144930.jpg', 30228, '8', 145175, 'TEL CEL 3G HUAWEI Y520', '145175.jpg', 6778),
(8, 145186, 'MINICOMP LG CM4350 3000W', '145186.jpg', 9998, 8, 145384, 'TEL CEL 3G LG Y30 JOY', '145384.jpg', 6992, 8, 145499, 'ABAN PIE SANKEY FN1746 16"', '145499.jpg', 2423, '8', 145573, 'LAV AUTO FRIGID FWIL20F3MNW 20KG BLC', '145573.jpg', 24542),
(8, 146044, 'REF SXS FRIGID FFSS2614QS 26CF 736L INOX', '146044.jpg', 73998, 8, 146146, 'TABLET HUAWEI MEDIA PAD T1 7" 8GB 3G', '146146.jpg', 7870, 8, 146149, 'REF AUTO LG GT29BPP 9CF 272L INOX', '146149.jpg', 23990, '8', 146153, 'JGO COMEDOR TRISWIFT FRANKLIN 4 S', '146153.jpg', 7867),
(8, 146346, 'REF AUTO FRIGID FRT40K3MPS 14CF405L INOX', '146346.jpg', 28749, 8, 146568, 'LAV AUTO FRIGID FWAC19H4MSMNW 19KG BLC', '146568.jpg', 27787, 8, 146637, 'COC GAS MABE EM5132BI01 20" 4Q BLC', '146637.jpg', 10979, '8', 146693, 'MOTO SERPENTO CLICK 150 AZ 2016', '146693.jpg', 58845),
(8, 146694, 'MOTO SERPENTO DEFENDER 150 NEG 2016', '146694.jpg', 55944, 8, 146695, 'MOTO SERPENTO DEFENDER 150 VER 2016', '146695.jpg', 56335, 8, 146699, 'MOTO SERPENTO CORAL 150 NEG 2016', '146699.jpg', 48527, '8', 146700, 'MOTO SERPENTO CORAL 150 ROJ 2016', '146700.jpg', 49366),
(8, 146704, 'MOTO SERPENTO NAGA 200 NEG 2016', '146704.jpg', 64807, 8, 146705, 'MOTO SERPENTO NAGA 200 ROJ 2016', '146705.jpg', 65422, 8, 146706, 'MOTO SERPENTO SPIRIT 250 ROJ 2016', '146706.jpg', 120312, '8', 146707, 'MOTO SERPENTO SPIRIT 250 BLC 2016', '146707.jpg', 120323),
(8, 146714, 'MOTO SERPENTO YARA S 200 AZ 2016', '146714.jpg', 69385, 8, 146715, 'MOTO SERPENTO YARA S200 ROJ 2016', '146715.jpg', 69450, 8, 146899, 'RADIOGRAB SONY ZSPS50 MP3', '146899.jpg', 5598, '8', 146974, 'TEATRO EN CASA C/DVD LG LHD625', '146974.jpg', 15108),
(8, 146981, 'PERCOLADOR HBEACH 40516 42TZ', '146981.jpg', 3191, 8, 147478, 'LAV SEMI TELSTAR TLS13050CF 13KG BLC', '147478.jpg', 8714, 8, 147899, 'COMP PORT HP 14AC111LA CI3 1TB 14" W10', '147899.jpg', 33472, '8', 148044, 'ROPERO FAMESA OCRE COLONIAL WENGUE', '148044.jpg', 24481),
(8, 148110, 'TEL CEL 4G SAMSUNG GALAXY J5 LTE', '148110.jpg', 17015, 8, 148111, 'TEL CEL 4G SAMSUNG GALAXY J7 LTE', '148111.jpg', 22020, 8, 148139, 'CONG HTL FRIGID FFC18A3MNW 18CF BLC', '148139.jpg', 33293, '8', 148155, 'TV LED 24" TELSTAR TTL024430KK ISDBT', '148155.jpg', 9479),
(8, 148337, 'CENTRO ENTRET FAMESA NEW SHARI', '148337.jpg', 13434, 8, 148338, 'CENTRO ENTRET FAMESA BROOKLYN', '148338.jpg', 10188, 8, 148350, 'OLLA ARROC B&D RC5280 30TZ', '148350.jpg', 2904, '8', 148397, 'CENTRO ENTRET FAMESA MEDIEVAL', '148397.jpg', 23694),
(8, 148402, 'CENTRO ENTRET FAMESA MANHATHAN', '148402.jpg', 12340, 8, 148419, 'TEL CEL 4G SAMSUNG GALAXY A3 2016', '148419.jpg', 25903, 8, 148510, 'CONG HTL FRIGID FFC09A3MPW 9CF BLC', '148510.jpg', 16635, '8', 148511, 'CONG HTL FRIGID FFC15A3MNW 15CF BLC', '148511.jpg', 24918),
(8, 148781, 'TEL CEL 4G SAMSUNG GALAXY J2 LTE', '148781.jpg', 12468, 8, 148948, 'MULTIFUNCIONAL INYEC HP UIA4535', '148948.jpg', 4958, 8, 149049, 'ABAN TORRE LASKO 2535 52"', '149049.jpg', 4984, '8', 149058, 'JGO SALA DULER COLIMA 32 CAF', '149058.jpg', 25960),
(8, 149059, 'JGO SALA DULER COLIMA 32 TERRACOTA', '149059.jpg', 25773, 8, 149060, 'JGO SALA DULER WYN ESQ TERRACOTA', '149060.jpg', 37213, 8, 149061, 'JGO SALA DULER WYN ESQ TURQ', '149061.jpg', 36682, '8', 149064, 'JGO SALA DULER MONTREAL TERRACOTA', '149064.jpg', 47753),
(8, 149065, 'JGO SALA DULER BALI 32 CAF', '149065.jpg', 28210, 8, 149066, 'JGO SALA DULER BALI 32 ROJ', '149066.jpg', 28485, 8, 149084, 'LICUADORA HBEACH 58148 VID 4 V', '149084.jpg', 2033, '8', 149085, 'EXTRACTOR HBEACH 67801', '149085.jpg', 1892),
(8, 149088, 'PARRILLA ELEC HBEACH 38546', '149088.jpg', 3569, 8, 149343, 'JGO SALA VASQUEZ URBAN BEIGE', '149343.jpg', 19943, 8, 149532, 'MINICOMP LG CM4360 2500W', '149532.jpg', 9183, '8', 149626, 'TV LED 28" TELSTAR TTL028430KK ISDBT', '149626.jpg', 10798),
(8, 149629, 'COC GAS FRIGID FKGM30C3BBPG 30" 5Q GRIS', '149629.jpg', 17884, 8, 149695, 'CONG HTL LG GC34BPW 12CF INOX', '149695.jpg', 20503, 8, 149750, 'TV LED 20" TELSTAR TTL020230KK ISDBT', '149750.jpg', 7378, '8', 149862, 'MINICOMP LG CM4460 5300W', '149862.jpg', 11916),
(8, 149863, 'MINICOMP LG CM4560 8000W', '149863.jpg', 15238, 8, 149864, 'MINICOMP LG CM8460 32000W', '149864.jpg', 29531, 8, 149866, 'MINICOMP LG CM5760 13200W', '149866.jpg', 17871, '8', 149887, 'JGO SALA CAPRI SINAI AZ', '149887.jpg', 19998),
(8, 149888, 'JGO SALA CAPRI SINAI VERD', '149888.jpg', 19998, 8, 149890, 'JGO SALA CAPRI SINAI CAF', '149890.jpg', 19998, 8, 149891, 'TEL CEL 4G SAMSUNG GALAXY J3', '149891.jpg', 14782, '8', 149989, 'CAFETERA HBEACH 46201 12TZ', '149989.jpg', 3849),
(8, 149990, 'CAFETERA HBEACH 43253R 12TZ', '149990.jpg', 3567, 8, 149995, 'HORNO TOST HBEACH 22722', '149995.jpg', 2883, 8, 150022, 'PLANCHA B&D IR1820 VAPOR', '150022.jpg', 1161, '8', 150029, 'TV LED 48" SONY KDL48W655D LA8 SMART', '150029.jpg', 49085),
(8, 150046, 'TV LED 43" TELSTAR TTL043430KK ISDBT', '150046.jpg', 21596, 8, 150116, 'MINICOMP LG CM9960 52800W', '150116.jpg', 64599, 8, 150134, 'TV LED 32" LG 32LH510B', '150134.jpg', 16598, '8', 150140, 'TV LED 43" LG 43LH5100', '150140.jpg', 25006),
(8, 150255, 'REF SEMI CETRON RCC300WNS 11CF 325L GRAF', '150255.jpg', 15669, 8, 150344, 'JGO COMEDOR PRIMIUN MADRID 4 S', '150344.jpg', 14358, 8, 150380, 'TEL CEL 4G HUAWEI GR5', '150380.jpg', 24426, '8', 150381, 'TEL CEL 3G SAMSUNG GALAXY J1 MINI', '150381.jpg', 7198),
(8, 150493, 'JGO SALA CAPRI NOVA MODULAR 32', '150493.jpg', 25494, 8, 150494, 'JGO SALA CAPRI DELUXE ESQUINERA 22', '150494.jpg', 23292, 8, 150541, 'MOTO SERPENTO TAYPAN 150 ROJ 2017', '150541.jpg', 43206, '8', 150548, 'MOTO SERPENTO COBRA 150 NEG 2017', '150548.jpg', 51519),
(8, 150549, 'MOTO SERPENTO COBRA 150 ROJ 2017', '150549.jpg', 51516, 8, 150637, 'LAV AUTO WHIRLP 7MWTW1500EM 15KG BLC', '150637.jpg', 25505, 8, 150672, 'MOTO SERPENTO BOA 150CC NEG 2017', '150672.jpg', 66352, '8', 150673, 'MOTO SERPENTO BOA 150CC ROJ 2017', '150673.jpg', 66208),
(8, 150888, 'JGO SALA MERJEN MALAGA ESQUINERO', '150888.jpg', 24530, 8, 150890, 'JGO SALA MERJEN BOREAL ROJ', '150890.jpg', 22797, 8, 150893, 'JGO SALA MERJEN BOREAL TURQ', '150893.jpg', 22710, '8', 150894, 'JGO SALA MERJEN BOREAL CAF OSCURO', '150894.jpg', 22518),
(8, 151069, 'MOTO SERPENTO TAYPAN 150 NEG 2017', '151069.jpg', 43178, 8, 151091, 'TEL CEL 3G HUAWEI Y5 II', '151091.jpg', 8481, 8, 151168, 'TV LED 24" LG 24MT48', '151168.jpg', 10598, '8', 151325, 'OLLA ARROC B&D RC5200M INOX 20TZ', '151325.jpg', 2329),
(8, 151376, 'TEL CEL 4G SAMSUNG GALAXY J1 2016', '151376.jpg', 11645, 8, 151795, 'COC GAS MABE EM7671CFIX0 30" 6Q INOX', '151795.jpg', 24998, 8, 151800, 'LAV AUTO MABE LMA77113CBAB0 17KG BLC', '151800.jpg', 22305, '8', 152005, 'COMP PORT LENOVO B4080 14" I3 500GB W10', '152005.jpg', 27998),
(8, 152065, 'MOTO SERPENTO DRACO 200 ROJ/NEG 2017', '152065.jpg', 80499, 8, 152067, 'MOTO SERPENTO DRACO 200 NEG MATTE 2017', '152067.jpg', 80499, 8, 152089, 'COMP PORT LENOVO N22 N3050 4GB32GB 11.6"', '152089.jpg', 14304, '0', 0, '', '', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `IdUsuario` int(50) NOT NULL COMMENT 'Id de usuario',
  `Usuario` varchar(100) NOT NULL COMMENT 'Usuario',
  `Nombre` varchar(150) DEFAULT NULL COMMENT 'Nombre del usuario',
  `Clave` varchar(100) NOT NULL COMMENT 'Contraseña de Usuario',
  `Rol` varchar(100) NOT NULL COMMENT 'Tipo de Usuario',
  `IdCL` varchar(10) NOT NULL COMMENT 'Id del Cliente',
  `Cliente` varchar(250) DEFAULT NULL COMMENT 'Nombre del Cliente',
  `Zona` varchar(250) DEFAULT NULL COMMENT 'Nombre de Vendedor o Ruta',
  `Estado` bit(1) DEFAULT NULL COMMENT '0 Activo, 1 Inactivo',
  `FechaCreacion` datetime NOT NULL COMMENT 'Fecha de Creación del Usuario',
  `FechaBaja` datetime DEFAULT NULL COMMENT 'Fecha de Baja del Usuario'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`IdUsuario`, `Usuario`, `Nombre`, `Clave`, `Rol`, `IdCL`, `Cliente`, `Zona`, `Estado`, `FechaCreacion`, `FechaBaja`) VALUES
(1, 'admin', 'admin', '202cb962ac59075b964b07152d234b70', 'Administrador', '', NULL, '', b'0', '2016-06-27 00:00:00', '0000-00-00 00:00:00'),
(220, 'alder', 'alder', '202cb962ac59075b964b07152d234b70', 'SuperAdministrador', '', NULL, NULL, b'0', '2016-09-22 13:31:24', NULL),
(329, 'ana.bello', 'ana.bello', '202cb962ac59075b964b07152d234b70', 'Cliente', '03000', 'FARMACIA MERIDIONAL', 'F05', b'0', '2016-12-05 18:51:42', NULL),
(334, 'sac', 'sac', '202cb962ac59075b964b07152d234b70', 'SAC', '', NULL, NULL, b'0', '2016-12-06 15:40:44', NULL),
(335, 'F03', 'vendedor', '202cb962ac59075b964b07152d234b70', 'Vendedor', '', NULL, 'F03', b'0', '2016-12-06 15:48:14', NULL),
(336, 'cartera', 'cartera', '202cb962ac59075b964b07152d234b70', 'Cartera', '', NULL, NULL, b'0', '2016-12-06 16:15:28', NULL),
(337, 'meridional', 'meridional', '202cb962ac59075b964b07152d234b70', 'Cliente', '03000', 'FARMACIA MERIDIONAL', 'F03', b'0', '2016-12-06 16:22:27', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vendedor`
--

CREATE TABLE `vendedor` (
  `IdVendedor` int(10) NOT NULL,
  `Nombre` varchar(150) NOT NULL,
  `Zona` varchar(20) NOT NULL,
  `Estado` bit(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `vendedor`
--

INSERT INTO `vendedor` (`IdVendedor`, `Nombre`, `Zona`, `Estado`) VALUES
(1, 'F01', 'F01', b'0'),
(2, 'F02', 'F02', b'0'),
(3, 'F03', 'F03', b'0'),
(4, 'F04', 'F04', b'0'),
(5, 'F05', 'F05', b'0'),
(6, 'F06', 'F06', b'0'),
(7, 'F07', 'F07', b'0'),
(8, 'F08', 'F08', b'0'),
(9, 'F09', 'F09', b'0'),
(10, 'F10', 'F010', b'0'),
(11, 'F11', 'F011', b'0'),
(12, 'F12', 'F012', b'0'),
(13, 'F13', 'F013', b'0'),
(14, 'F14', 'F014', b'0'),
(15, 'F15', 'F015', b'0'),
(16, 'F16', 'F016', b'0'),
(17, 'F17', 'F017', b'0'),
(18, 'F18', 'F018', b'0'),
(19, 'F19', 'F019', b'0'),
(20, 'F20', 'F020', b'0'),
(21, 'F21', 'F021', b'0');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_all_fre`
--
CREATE TABLE `view_all_fre` (
`Fecha` datetime
,`IdFRE` varchar(11)
,`IdCliente` varchar(255)
,`Nombre` varchar(255)
,`Puntos` decimal(32,0)
,`Efectivo` decimal(32,0)
,`Anulado` varchar(255)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_canje_premios`
--
CREATE TABLE `view_canje_premios` (
`IdFRP` int(10)
,`Fecha` datetime
,`IdCliente` varchar(10)
,`Nombre` varchar(50)
,`IdArticulo` int(10)
,`Descripcion` varchar(50)
,`CANTIDAD` decimal(45,4)
,`PUNTO` decimal(45,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_catalogo_activo`
--
CREATE TABLE `view_catalogo_activo` (
`IdIMG` varchar(15)
,`Nombre` varchar(255)
,`IMG` varchar(150)
,`Puntos` int(20)
,`Descripcion` varchar(150)
,`IdCT` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_clientesactivos`
--
CREATE TABLE `view_clientesactivos` (
`CLIENTES` text
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_fre_factura`
--
CREATE TABLE `view_fre_factura` (
`IdFRE` varchar(11)
,`Factura` varchar(255)
,`IdCliente` varchar(255)
,`Puntos` int(11)
,`Efectivo` int(11)
,`Anulado` varchar(255)
,`Fecha` datetime
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_frp_articulo`
--
CREATE TABLE `view_frp_articulo` (
`IdFRP` int(10)
,`Fecha` datetime
,`IdCliente` varchar(10)
,`Nombre` varchar(50)
,`IdArticulo` int(10)
,`Descripcion` varchar(50)
,`CANTIDAD` decimal(45,4)
,`PUNTO` decimal(45,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_frp_factura`
--
CREATE TABLE `view_frp_factura` (
`IdFRP` int(10)
,`IdCliente` varchar(10)
,`Faplicado` int(20)
,`Factura` varchar(10)
,`Fecha` varchar(15)
,`Puntos` decimal(41,0)
,`SALDO` decimal(42,0)
,`Anulado` varchar(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vt_clientesuser`
--
CREATE TABLE `vt_clientesuser` (
`CLIENTES` text
);

-- --------------------------------------------------------

--
-- Estructura para la vista `fr_total`
--
DROP TABLE IF EXISTS `fr_total`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `fr_total`  AS  select distinct `view_frp_factura`.`Factura` AS `FACTURA`,`view_frp_factura`.`SALDO` AS `SALDO` from `view_frp_factura` union all select distinct `view_fre_factura`.`Factura` AS `FACTURA`,1 AS `1` from `view_fre_factura` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_all_fre`
--
DROP TABLE IF EXISTS `view_all_fre`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_all_fre`  AS  select `fre`.`Fecha` AS `Fecha`,`fre`.`IdFRE` AS `IdFRE`,`fre`.`IdCliente` AS `IdCliente`,`fre`.`Nombre` AS `Nombre`,sum(`detallefre`.`Puntos`) AS `Puntos`,sum(`detallefre`.`Efectivo`) AS `Efectivo`,`fre`.`Anulado` AS `Anulado` from (`fre` join `detallefre` on((`fre`.`IdFRE` = `detallefre`.`IdFRE`))) group by `fre`.`IdFRE`,`fre`.`Anulado` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_canje_premios`
--
DROP TABLE IF EXISTS `view_canje_premios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_canje_premios`  AS  select `t0`.`IdFRP` AS `IdFRP`,`t1`.`Fecha` AS `Fecha`,`t1`.`IdCliente` AS `IdCliente`,`t1`.`Nombre` AS `Nombre`,`t0`.`IdArticulo` AS `IdArticulo`,`t0`.`Descripcion` AS `Descripcion`,(select (sum(`t0`.`Puntos`) / `t2`.`Puntos`) from `detallect` `t2` where ((`t0`.`IdCT` = `t2`.`IdCT`) and (`t0`.`IdArticulo` = `t2`.`IdIMG`))) AS `CANTIDAD`,(sum(`t0`.`Puntos`) / `t0`.`Cantidad`) AS `PUNTO` from (`detallefrp` `t0` join `frp` `t1` on((`t1`.`IdFRP` = `t0`.`IdFRP`))) where (`t1`.`Anulado` = 'N') group by `t0`.`IdFRP`,`t0`.`IdArticulo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_catalogo_activo`
--
DROP TABLE IF EXISTS `view_catalogo_activo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_catalogo_activo`  AS  select `detallect`.`IdIMG` AS `IdIMG`,`detallect`.`Nombre` AS `Nombre`,`detallect`.`IMG` AS `IMG`,`detallect`.`Puntos` AS `Puntos`,`catalogo`.`Descripcion` AS `Descripcion`,`catalogo`.`IdCT` AS `IdCT` from (`catalogo` left join `detallect` on((`detallect`.`IdCT` = `catalogo`.`IdCT`))) where (`catalogo`.`Estado` = 0) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_clientesactivos`
--
DROP TABLE IF EXISTS `view_clientesactivos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_clientesactivos`  AS  select group_concat(concat('\'',`usuario`.`IdCL`,'\'') separator ',') AS `CLIENTES` from `usuario` where ((`usuario`.`IdCL` <> '') and (`usuario`.`Estado` <> 1)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_fre_factura`
--
DROP TABLE IF EXISTS `view_fre_factura`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_fre_factura`  AS  select `fre`.`IdFRE` AS `IdFRE`,`detallefre`.`Factura` AS `Factura`,`fre`.`IdCliente` AS `IdCliente`,`detallefre`.`Puntos` AS `Puntos`,`detallefre`.`Efectivo` AS `Efectivo`,`fre`.`Anulado` AS `Anulado`,`detallefre`.`Fecha` AS `Fecha` from (`fre` join `detallefre` on((`fre`.`IdFRE` = `detallefre`.`IdFRE`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_frp_articulo`
--
DROP TABLE IF EXISTS `view_frp_articulo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_frp_articulo`  AS  select `t0`.`IdFRP` AS `IdFRP`,`t1`.`Fecha` AS `Fecha`,`t1`.`IdCliente` AS `IdCliente`,`t1`.`Nombre` AS `Nombre`,`t0`.`IdArticulo` AS `IdArticulo`,`t0`.`Descripcion` AS `Descripcion`,(select (sum(`t0`.`Puntos`) / `t2`.`Puntos`) from `detallect` `t2` where ((`t0`.`IdCT` = `t2`.`IdCT`) and (`t0`.`IdArticulo` = `t2`.`IdIMG`))) AS `CANTIDAD`,(sum(`t0`.`Puntos`) / `t0`.`Cantidad`) AS `PUNTO` from (`detallefrp` `t0` join `frp` `t1` on((`t1`.`IdFRP` = `t0`.`IdFRP`))) where (`t1`.`Anulado` = 'N') group by `t0`.`IdFRP`,`t0`.`IdArticulo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_frp_factura`
--
DROP TABLE IF EXISTS `view_frp_factura`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_frp_factura`  AS  select `t0`.`IdFRP` AS `IdFRP`,(select `t1`.`IdCliente` from `frp` `t1` where (`t1`.`IdFRP` = `t0`.`IdFRP`)) AS `IdCliente`,`t0`.`Faplicado` AS `Faplicado`,`t0`.`Factura` AS `Factura`,`t0`.`Fecha` AS `Fecha`,sum(`t0`.`Puntos`) AS `Puntos`,(`t0`.`Faplicado` - (select sum(`t1`.`Puntos`) from `detallefrp` `t1` where ((`t1`.`IdFRP` = `t0`.`IdFRP`) and (`t1`.`Factura` = `t0`.`Factura`)))) AS `SALDO`,(select `t1`.`Anulado` from `frp` `t1` where (`t1`.`IdFRP` = `t0`.`IdFRP`)) AS `Anulado` from `detallefrp` `t0` group by `t0`.`Factura`,`t0`.`IdFRP`,`t0`.`Faplicado` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vt_clientesuser`
--
DROP TABLE IF EXISTS `vt_clientesuser`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vt_clientesuser`  AS  select group_concat(concat('\'',`usuario`.`IdCL`,'\'') separator ',') AS `CLIENTES` from `usuario` where (`usuario`.`IdCL` <> '') ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `catalogo`
--
ALTER TABLE `catalogo`
  ADD PRIMARY KEY (`IdCT`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`IdRol`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`IdUsuario`);

--
-- Indices de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`IdVendedor`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `catalogo`
--
ALTER TABLE `catalogo`
  MODIFY `IdCT` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `IdUsuario` int(50) NOT NULL AUTO_INCREMENT COMMENT 'Id de usuario', AUTO_INCREMENT=338;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
