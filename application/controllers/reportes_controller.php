<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Reportes_controller extends CI_Controller
{
    public function __construct(){
        parent::__construct();
        $this->load->library('session');
        if($this->session->userdata('logged')==0){ //No aceptar a usuarios sin loguearse
            redirect(base_url().'index.php/login','refresh');
        }
        $this->load->model('canje_model');
        $this->load->model('cliente_model');
        $this->load->model('reportes_model');
    }
    public function index()
    {
    	$data = $this->cliente_model->ListarClientes();
    	$this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/Reportes',$data);
        $this->load->view('footer/footer');
        $this->load->view('jsview/js_reportes');
    }
    public function cuentaXcliente()
    {
        if ($_GET['fecha1']=="") {
            $fecha1 = '2012-01-01';
            $fecha2 = date('Y-m-d');
        }else{
            $fecha1 = $_GET['fecha1'];
            $fecha2 = $_GET['fecha2'];
        }
        $this->reportes_model->cuentaXcliente($_GET['codigo'],$fecha1,$fecha2);
    }
    public function format($fecha)
    {
        return $fecha = date("Y-m-d", strtotime($fecha));
    }
    public function datosCliente($codigo)
    {
        $this->reportes_model->datosCliente($codigo);
    }
    public function masterClientes($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->masterClientes($fecha1,$fecha2);
    }
    public function masterCompras($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->masterCompras($fecha1,$fecha2);
    }
    public function canjePremios($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->canjePremios($fecha1,$fecha2);
    }
    public function masterFacturas($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->masterFacturas($fecha1,$fecha2);
    }
    public function reporteXfecha($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->reporteXfecha($fecha1,$fecha2);
    }
    public function movimientoProductos($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->movimientoProductos($fecha1,$fecha2);
    }
    public function clientes_nuevos($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $fecha1;
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $fecha2;
        $this->reportes_model->clientes_nuevos($fecha1,$fecha2);
    }
    public function mas_vendidos($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $this->format($fecha1);
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $this->format($fecha2);
        $this->reportes_model->mas_vendidos($fecha1,$fecha2);
    }
    public function menos_vendidos($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $this->format($fecha1);
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $this->format($fecha2);
        $this->reportes_model->menos_vendidos($fecha1,$fecha2);
    }
    public function puntosXcliente($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $this->format($fecha1);
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $this->format($fecha2);
        $this->reportes_model->puntosXcliente($fecha1,$fecha2);
    }
    public function canjes($fecha1,$fecha2)
    {
        $fecha1 = ($fecha1=="") ? '2014-01-01' : $this->format($fecha1);
        $fecha2 = ($fecha1=="") ? date('Y-m-d') : $this->format($fecha2);
        $this->reportes_model->canjes($fecha1,$fecha2);
    }
}