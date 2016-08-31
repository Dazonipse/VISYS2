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
$route['Clientes'] = 'vista_controller/Clientes';
$route['FindClient/(:any)'] = 'clientes_controller/FindClient/$1';

$route['BajaClientes'] = 'vista_controller/BajaClientes';
$route['PuntosClientes'] = 'vista_controller/PuntosClientes';
$route['DetalleFact'] = 'vista_controller/DetalleFact';
$route['Frp'] = 'vista_controller/CanjeFrp';
$route['FRE'] = 'vista_controller/CanjeFre';
$route['Catalogo'] = 'vista_controller/Catalogo';

/*USUARIOS*/
$route['Usuarios'] = 'vista_controller/Usuarios'; //cargar usuarios
$route['NuevoUsuario/(:any)/(:any)/(:any)/(:any)'] = 'Usuario_controller/addUser/$1/$2/$3/$4'; //agregar usuario
$route['ActUser/(:any)/(:any)'] = 'Usuario_controller/ActUser/$1/$2'; //cambiar estado de usuario
$route['LoadVendedores'] = 'Usuario_controller/LoadVendedor';
$route['LoadCliente'] = 'Usuario_controller/LoadClient';// cargar los clientes
/*USUARIOS*/

$route['Reportes'] = 'vista_controller/Reportes';

// FIN RUTAS MENU


// RUTA IMPRESION
$route['DetalleFRP'] = 'impresion_controller/DetalleFRP';
$route['DetalleFRE'] = 'impresion_controller/DetalleFRE';
// FIN IMPRESION

// RUTA EXPORTACIÓN
$route['Exp_Clientes'] = 'exportacion_controller/ExpoClients';
$route['ExpPDF'] = 'exportacion_controller/ExpoPdf';
// FIN EXPORTACIÓN


