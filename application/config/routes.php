<?php
defined('BASEPATH') OR exit('No direct script access allowed');

$route['default_controller'] = 'login_controller';
$route['404_override'] = '';
$route['translate_uri_dashes'] = FALSE;

/******** MIS RUTAS **********/
// LOGIN
$route['login'] = 'login_controller/Acreditar';
$route['salir'] = 'login_controller/Salir';
// FIN LOGIN

// RUTAS MENU
$route['Main'] = 'vista_controller/main';
$route['EliminarVineta'] = 'vista_controller/EliminarVineta';

/* CLIENTES */
$route['Clientes'] = 'clientes_controller/Clientes';
$route['FindClient/(:any)'] = 'clientes_controller/FindClient/$1';
$route['BajaClientes'] = 'clientes_controller/BajaClientes';
$route['PuntosClientes'] = 'clientes_controller/PuntosClientes';
$route['generarUsuarios'] = 'clientes_controller/generarUsuarios';
$route['traerUsuario/(:any)'] = 'clientes_controller/traerUsuario/$1';
$route['darBajaCliente'] = 'clientes_controller/darBajaCliente';

$route['DetalleFact'] = 'vista_controller/DetalleFact';

/*CANNJES FRP FRE*/
$route['Frp'] = 'canje_controller';
$route['FRE'] = 'vista_controller/CanjeFre';

/*USUARIOS*/
$route['Usuarios'] = 'vista_controller/Usuarios'; //cargar usuarios
$route['NuevoUsuario/(:any)/(:any)/(:any)/(:any)'] = 'Usuario_controller/addUser/$1/$2/$3/$4'; //agregar usuario
$route['ActUser/(:any)/(:any)'] = 'Usuario_controller/ActUser/$1/$2'; //cambiar estado de usuario
$route['LoadVendedores'] = 'Usuario_controller/LoadVendedor';
$route['LoadCliente'] = 'Usuario_controller/LoadClient';// cargar los clientes
/*USUARIOS*/

// RUTA FACTURAS
$route['facturas'] = 'facturas_controller';
$route['detallefacturas/(:any)'] = 'facturas_controller/detallefacturas/$1';
// RUTA REPORTES
$route['Reportes'] = 'vista_controller/Reportes';

/*RUTAS DE CATALOGO*/
$route['NuevoCatalogo'] = 'catalogo_controller/NuevoCatalogo';
$route['Catalogo'] = 'catalogo_controller/index';
$route['subirImg'] = 'catalogo_controller/subirImg';
$route['crearCatalogo'] = 'catalogo_controller/crearCatalogo';
$route['verificarImg/(:any)'] = 'catalogo_controller/verificarImg/$1';//verifico si la imagen existe ekisde
$route['ActualizarEstadoArticulo'] = 'catalogo_controller/ActualizarEstadoArticulo';
$route['AjaxCatalogoPasado/(:any)'] = 'catalogo_controller/CatalogoPasado/$1';
$route['actualizarPuntos/(:any)/(:any)/(:any)'] = 'catalogo_controller/actualizarPuntos/$1/$2/$3';
$route['actualizarCatalogo'] = 'catalogo_controller/actualizarCatalogo';//ruta para guardar los nuevos articulos en el catalogo
$route['getArticulosInactivos'] = 'catalogo_controller/getArticulosInactivos';
$route['subirVariasImagenes'] = 'catalogo_controller/subirVariasImagenes';
$route['activarArticulos/(:any)'] = 'catalogo_controller/activarArticulos/$1';
// FIN CATALOGO

// RUTA IMPRESION
$route['DetalleFRP'] = 'impresion_controller/DetalleFRP';
$route['DetalleFRE'] = 'impresion_controller/DetalleFRE';
// FIN IMPRESION

// RUTA EXPORTACIÓN
$route['Exp_Clientes'] = 'exportacion_controller/ExpoClients';
$route['ExpPDF'] = 'exportacion_controller/ExpoPdf';
$route['ExpPDF_PuntosClientes'] = 'exportacion_controller/ExpPDF_PuntosClientes';
$route['ExpEXCEL_PuntosClientes'] = 'exportacion_controller/ExpEXCEL_PuntosClientes';
// FIN EXPORTACIÓN
