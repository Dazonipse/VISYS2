<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Login_controller extends CI_Controller 
{

	public function __construct()
        {
            parent::__construct();
            $this->load->model('login_model');
            $this->load->library('session');
            

        }

    public function index()
    {
    	$this->load->view('header/header_login');
    	$this->load->view('login/login');
    	$this->load->view('footer/footer_login');
    }
     public function Salir(){        
        $this->session->sess_destroy();
        $sessiondata = array(
                'logged' => 0
        );

        $this->session->unset_userdata($sessiondata);
        $this->index();
	}
	 public function Acreditar(){
    	$this->form_validation->set_rules('txtUsuario', 'nombre', 'required');
		$this->form_validation->set_rules('txtpassword', 'pass', 'required');
    	
        if ($this->form_validation->run()== FALSE) {
    		 redirect('?error=1'); 
    	} else {
    		$name = $this->input->get_post('txtUsuario');
			$pass = $this->input->get_post('txtpassword');

			

            //echo md5($pass);
           $data['user'] = $this->login_model->login($name, $pass);

           
    		 if ($data['user'] == 0) {
    			redirect('?error=2'); 
    		} else {
                $sessiondata = array(
                                'id' => $data['user'][0]['IdUsuario'],
                                'UserN' => $data['user'][0]['NombreUsuario'],
                                'Permiso' => $data['user'][0]['Privilegio'],
                                'logged' => 1
                                );
                $this->session->set_userdata($sessiondata);               
                //print_r($sessiondata);
                if($this->session->userdata)
                {
                    redirect('Main');
                }
                /* if($this->session->userdata('Permiso')=='2')
                {
                    redirect('cardista');
                }*/
    			 
    		}
    	}
    }//fin de la fx


 }