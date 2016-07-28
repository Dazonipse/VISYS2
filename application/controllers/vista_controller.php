<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Vista_controller extends CI_Controller
{

    public function __construct(){
        parent::__construct();
    }

    public function main(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/main');
        $this->load->view('footer/footer');
    }

    public function EliminarVineta(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/EliminarVineta');
        $this->load->view('footer/footer');
    }

    public function Clientes(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/Clientes');
        $this->load->view('footer/footer');
    }

    public  function BajaClientes(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/BajaClientes');
        $this->load->view('footer/footer');
    }

    public  function  PuntosClientes(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/PuntosClientes');
        $this->load->view('footer/footer');
    }

    public function DetalleFact(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/DetalleFact');
        $this->load->view('footer/footer');
    }

    public function CanjeFrp(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/CanjeFRP');
        $this->load->view('footer/footer');
    }

    public function CanjeFre(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/CanjeEfec');
        $this->load->view('footer/footer');
    }

    public function Catalogo(){
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/Catalogo');
        $this->load->view('footer/footer');
    }
/*Funionalidad de Usuario*/
    public function Usuarios($bandera=null) // CARGAR USUARIOS
    {
        $query['Luser']=$this->User_model->LoadUser();
        $query['Lrol']=$this->User_model->LoadRol();
        $query['Lven']=$this->User_model->LoadVendedor();
        if ($bandera==null) {$bandera=0;}else{$bandera=1;}
        $query['LMod']= array('bandera'=>$bandera);
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/Users',$query);
        $this->load->view('footer/footer');
    }
    public function addUser()// AGREGAR USUARIO
    {
        $this->form_validation->set_rules('user', 'Campo', 'required');
        $this->form_validation->set_rules('pass', 'Campo', 'required');
            if ($this->form_validation->run()== FALSE) {
                $this->Usuarios();
            }
        else
        {
            $nombre =$this->input->post('user');
            $clave = $this->input->post('pass');
            $rol =$this->input->post('rol');
            $vendedor =$this->input->post('vendedor');
            $fecha =  date('Y-m-d');
            $query = $this->User_model->addUser($nombre,$clave,$rol,$fecha,$vendedor);
                if ($query==1) {
                    redirect('Usuarios');
                }
            $bandera=1;
            //$this->Usuarios($bandera);
            //redirect(base_url().'index.php/Usuarios','refresh');
        }
    }
    public function ActUser($IdUser,$Estado) /*ELIMINAR USUARIO*/
    {
       $this->User_model->ActUser($IdUser,$Estado);

        /*if($data){
            redirect('Usuarios');
        }*/
    }

    /*Funionalidad de Usuario*/
    public function Reportes()
    {
        $this->load->view('header/header');
        $this->load->view('pages/menu');
        $this->load->view('pages/Reportes');
        $this->load->view('footer/footer');
    }

}