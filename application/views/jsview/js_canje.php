
<script>
	$( document ).ready(function(){
	//$('#MFrp').openModal();
    function limpiarTabla (idTabla) {
        idTabla = $(idTabla).DataTable();
        idTabla.destroy();
        idTabla.clear();
        idTabla.draw();
    }
    $('#searchFRP').on( 'keyup', function () {
        var table = $('#tblFRP').DataTable();
        table.search( this.value ).draw();
    } );
	$('#tblFacturaFRP,#tblFRP,#tblpRODUCTOS').DataTable(
    {
            "info":    false,
            //"searching": false,
            "bLengthChange": false,
            "lengthMenu": [[5,16,32,100,-1], [5,16,32,100,"Todo"]],
            "language": {
                "paginate": {
                    "first":      "Primera",
                    "last":       "Última ",
                    "next":       "Siguiente",
                    "previous":   "Anterior"
                },
                "lengthMenu":"MOSTRAR _MENU_",
                "emptyTable": "No hay datos disponibles en la tabla",
                "search":     "<i class='material-icons'>search</i>" 
            }
        }
    );

    $( "#ListCliente").change(function() {
        var Cls = $(this).val();

        if(Cls !=0){
            $.ajax({
                url: "getAplicadoP/"+ Cls,
                type: "post",
                async:true,
                success:
                    function(clsAplicados){
                        $("#PtosDisponibles").val(parseInt(clsAplicados));
                    }
            });
            $("#txtCodCliente,#ClienteFRPPremio").val(Cls);
            limpiarTabla(tblFacturaFRP);
            $('#tblFacturaFRP').DataTable({
                ajax: "getFacturaFRP/"+ Cls,
                "info":    false,
                "bPaginate": false,
                "paging": false,
                "pagingType": "full_numbers",
                columns: [
                    { "data": "FECHA" },
                    { "data": "FACTURA" },
                    { "data": "DISPONIBLE" },
                    { "data": "CAM1" },
                    { "data": "CAM2" },
                    { "data": "CAM3" },
                    { "data": "CAM4" },
                ]
            });
        }else{
            alert("No Selecciono ningun cliente");
        }
    });

    $( "#ListCatalogo").change(function() {
        if ($("#ListCliente").val()!=0){
            $("#AddPremioTbl").hide();
            $("#loadIMG").show();
            var Prm = $(this).val();
            $("#CodPremioFRP").val(Prm);
            $("#CantPremioFRP").val("1");

            var form_data = {
                codigo: Prm
            };
            $.ajax({
                url: "viewPtsItemCatalogo",
                type: "post",
                async:true,
                data: form_data,
                success:
                    function(json){
                        $("#ValorPtsPremioFRP").val(json)
                        $("#AddPremioTbl").show();
                        $("#loadIMG").hide();
                    }
            });
        }else{
            mensaje("SELECCIONE UN CLIENTE PRIMERO","error");
        }
    });


    $("#AddPremioTbl").on('click',function(){
        var Permitir = 0
        Objtable = $('#tblpRODUCTOS').DataTable();
        obj = $('#tblFacturaFRP').DataTable();
        obj.rows().data().each( function (index,value) {
            if($("#CHK" + obj.row(value).data().FACTURA).is(':checked') ) {
                Permitir = 1;
            }
        });

        var cod= $( "#ListCatalogo option:selected" ).val();
        cod = cod.split("|-|");
        cod = cod[0];
        var ttClPts = parseInt($("#PtosDisponibles").val());
        if (cod != 0){
            var name = $( "#ListCatalogo option:selected" ).html();
            var pts    = $("#ValorPtsPremioFRP").val();
            var cant   = $("#CantPremioFRP").val();
            var totalPts = parseInt(cant) * parseInt(pts);
            var ttPts = parseInt($("#idttPtsFRP").text());
            ttPts = ttPts + totalPts;
            //alert(ttPts+" y "+ttClPts);
            if (ttPts <= ttClPts){
                $("#idttPtsFRP").text(ttPts);
                Objtable.row.add( [
                    cant,
                    cod,
                    name,
                    pts,
                    totalPts,
                    '<a href="#!" id="RowDelete" class="BtnClose"><i class="material-icons">highlight_off</i></a>'
                ] ).draw( false );
                //$('#ListCatalogo').val("...").trigger('change');
                $("#CodPremioFRP,#ValorPtsPremioFRP,#CantPremioFRP").val("");
                apliAutomatic(ttPts);

            }else{
                mensaje("NO CUENTA CON LOS PUNTOS NECESARIOS","error");
            }
        }else{
            mensaje("SELECCIONE UN ARTICULO DEL CATALOGO","error");
        }
        $('#float-select-producto > option[value="0"]').attr('selected', 'selected');
    });
    

    function apliAutomatic(pts){
        var obj = $('#tblFacturaFRP').DataTable();
        var disp = 0;
        var sFactura = 0;
        obj.rows().data().each( function (index,value) {
            var FACTURA   = obj.row(value).data().FACTURA;
            $("#AP1" + FACTURA).html("");
            $("#DIS" + FACTURA).html("");
            $("#EST" + FACTURA).html("");
            $("#CHK"+FACTURA).prop('checked', false);
        });
        console.log(pts);
        if (pts > 0 ){
            obj.rows().data().each( function (index,value) {
                var FACTURA   =  obj.row(value).data().FACTURA;

                disp = parseInt(obj.row(value).data().DISPONIBLE)
                if (isNaN(parseInt($("#AP1" + FACTURA).text()))){ apl = 0 } else { apl = parseInt($("#AP1" + FACTURA).text()) }
                if (pts > 0){
                    if (disp >= pts){
                        sFactura = disp - pts;
                        $("#AP1" + FACTURA).html(pts);
                        pts = 0;
                        $("#DIS" + FACTURA).html(sFactura);
                    } else {
                        pts = pts - disp ;
                        $("#AP1" + FACTURA).html(disp);
                        $("#DIS" + FACTURA).html("0");
                    }
                }
                var ESTADO = $("#DIS" + FACTURA).text();
                if (ESTADO != ""){
                    if (parseInt(ESTADO) == 0){
                        $("#EST" + FACTURA).html("APLICADO");
                    } else {
                        $("#EST" + FACTURA).html("PARCIAL");
                    }
                    $("#CHK"+FACTURA).prop('checked', true);
                }
            });
        }//console.log("entro al apliautomatic");
    };
    
    $("#btnProcesar").click(function(){
        numFRP = $("#frp").val();
        var fchFRP = $("#date1").val();
        var pCambiar = $("#idttPtsCLsFRP").text();
        tblFactura = $("#tblFacturaFRP").DataTable();
        tblPremios = $("#tblpRODUCTOS").DataTable();
        mss = 'INGRESE NUMERO DE FRP.';

        $.ajax({
            url: "BuscaFRP/" + numFRP,
            type: "post",
            async:false,
            success:
                function(clsAplicados){
                    if (parseInt(clsAplicados) > 0) {
                        mss = 'NUMERO YA EXISTE!!!, INGRESE OTRO NUMERO DE FRP.';
                        numFRP = "";
                    }
                }
        });

        if ( (numFRP =="") || (numFRP.length < 4)){
            $("#frp").focus();
            mensaje(mss, "error");
        } else {
            if ( (fchFRP =="") && (fchFRP.length < 4) ){
                $("#frp").focus();
                mensaje("SELECCIONE LA FECHA.", "error");
            } else {
                if ( !tblFactura.data().any() ){
                    mensaje("TABLA DE FACTURAS VACIA.", "error");
                } else {
                    if ( !tblPremios.data().any() ){
                        mensaje("TABLA DE PREMIO VACIA.", "error");
                    } else {
                        if  ( pCambiar != 0){
                            mensaje("SELECCIONE LA FACTURAS A APLICAR.", "error");
                        } else {
                            $('#Dfrp').openModal();
                            $("#frpProgress").show();
                            $("#divTop,#divTbl").hide();
                            SaveFRP(numFRP,fchFRP);
                        }
                    }
                }
            }
        }
    });
        

   function SaveFRP(idFrp,Fecha){
        var linea = 0;
        var menos = 0;
        var remanente =0;
        var detallesFactura  = new Array();
        var logFactura       = new Array();
        var detallesArticulo = new Array();

        var i=0;

        var IdCliente = $( "#ListCliente option:selected" ).val();
        var Nombre    = $( "#ListCliente option:selected" ).html();

        obj = $('#tblpRODUCTOS').DataTable();
        ofact = $('#tblFacturaFRP').DataTable();
        total  = parseInt($("#idttPtsFRP").text());
        FPunto = 0;
        Posi=0;
        obj.rows().data().each( function (ip) {
            remanente = parseInt(ip[4]);
            
            ofact.rows().data().each( function (index,value) {
                var FAC = ofact.row(linea).data().FACTURA;
                var FCH = ofact.row(linea).data().FECHA;
                var FLPunto = ofact.row(linea).data().DISPONIBLE;
                valor = 0;
                apl = parseInt($("#AP1" + FAC).text());
                dis = parseInt($("#DIS" + FAC).text());
                est = ($("#EST" + FAC).text());
                
                if (FPunto == 0){FPunto = ofact.row(linea).data().DISPONIBLE;}
                
                if (remanente > apl){
                    valor = apl;
                    FPunto = FPunto - apl;
                }else{
                    valor = remanente;
                    FPunto = FPunto - remanente;

                    if (remanente != 0){apl = Math.abs(FPunto);}
                }

                if (remanente == 0) {
                    return false;
                } else {
                    console.log(FAC + "," + "Puntos:" + FLPunto +", Aplica: " + valor + ", Pendiente: " + apl);
                    detallesFactura[Posi] = idFrp+","+FAC+","+FLPunto+","+ip[1]+","+ip[2]+","+valor+","+ip[0]+","+FCH;
                    Posi++;
                }

                if (remanente > valor) {
                    remanente = remanente - apl;
                } else {
                    if (FPunto < 0) {
                        remanente = Math.abs(FPunto);
                        FPunto = 0;
                    } else {
                        remanente = 0;
                    }
                }
                linea++;
            });
            linea--
        });

        totalFinalFRP =0;

        obj = $('#tblpRODUCTOS').DataTable();
        var viewProductos     = new Array();
        obj.rows().data().each( function (index) {
            viewProductos[i]=new Array(5);
            detallesArticulo[i] = idFrp + "," + index[1] + "," + index[2] + "," + index[3] + "," + index[0];
            viewProductos[i][0] = index[0];
            viewProductos[i][1] = index[1];
            viewProductos[i][2] = index[2];
            viewProductos[i][3] = index[3];
            viewProductos[i][4] = index[4];
            totalFinalFRP += parseInt(index[4]);

            i++;
        });

        i=0;
        obj = $('#tblFacturaFRP').DataTable();
        var viewFacturas     = new Array();

        obj.rows().data().each( function (index,value) {
            var FAC = obj.row(value).data().FACTURA;
            var FCH = obj.row(value).data().FECHA;
            var FLPunto = obj.row(value).data().DISPONIBLE;
            var apl = $("#AP1" + FAC).text();
            dis = parseInt($("#DIS" + FAC).text());
            est = ($("#EST" + FAC).text());
            
            if($("#CHK"+FAC).is(':checked') ) {
                logFactura[i]      = IdCliente + "," + FAC + "," + apl+ "," + FLPunto;
                viewFacturas[i]=new Array(6);
                viewFacturas[i][0] = FCH;
                viewFacturas[i][1] = FAC;
                viewFacturas[i][2] = FLPunto;
                viewFacturas[i][3] = apl;
                viewFacturas[i][4] = dis;
                viewFacturas[i][5] = est;
                i++;
            }
        });

        $('#Dfrp').openModal();

        var form_data = {
            top: [idFrp, Fecha, IdCliente,Nombre],
            art: detallesArticulo,
            fac: detallesFactura,
            log: logFactura
        };

        $.ajax({
            url: "saveFRP",
            type: "post",
            async:true,
            data: form_data,
            success:
                function(data){
                    if (data==1){
                        $("#spnFRP").text(idFrp);
                        $("#spnFecha").text(Fecha);
                        $("#spnCodCls").text(IdCliente);
                        $("#spnNombreCliente").text(Nombre);

                        $('#tblModal1').DataTable( {
                            data: viewFacturas,
                            "info":    false,
                            //"order": [[ 2, "asc" ]],
                            //"searching": false,
                            "bLengthChange": true,
                            "bPaginate": false,
                            "lengthMenu": [[10,15,32,100,-1], [10,15,32,100,"Todo"]],
                            "language": {
                                "paginate": {
                                    "first":      "Primera",
                                    "last":       "Última ",
                                    "next":       "Siguiente",
                                    "previous":   "Anterior"
                                },
                                "lengthMenu":"Mostrar _MENU_",
                                "emptyTable": "No hay datos disponibles en la tabla",
                                "search":     ""},
                                columns: [
                                { title: "FECHA" },
                                { title: "BOUCHER" },
                                { title: "Pts." },
                                { title: "Pts. APLI." },
                                { title: "Pts. DISP." },
                                { title: "ESTADO" }
                            ]
                        } );

                        $('#tblModal2').DataTable( {
                            data: viewProductos,
                            "info":    false,
                            //"order": [[ 2, "asc" ]],
                            //"searching": false,
                            "bLengthChange": true,
                            "bPaginate": false,
                            "lengthMenu": [[10,15,32,100,-1], [10,15,32,100,"Todo"]],
                            "language": {
                                "paginate": {
                                    "first":      "Primera",
                                    "last":       "Última ",
                                    "next":       "Siguiente",
                                    "previous":   "Anterior"
                                },
                                "lengthMenu":"Mostrar _MENU_",

                                "emptyTable": "No hay datos disponibles en la tabla",
                                "search":     ""
                            },
                            columns: [
                                { title: "CANT." },
                                { title: "COD. PREMIO" },
                                { title: "DESCRIPCIÓN" },
                                { title: "Pts." },
                                { title: "TOTAL Pts." }
                            ]
                        } );

                        $("#spnTotalFRP").text(totalFinalFRP);



                        $("#frpProgress").hide();
                        $("#divTop,#divTbl").show();
                    } else {
                        mensaje("ERROR AL CREAR EL FRP","error");
                    }
                }
        });
    }
    $("#tblpRODUCTOS").delegate("a", "click", function(){console.log("entro");
            $('#tblpRODUCTOS').DataTable().row('.selected').remove().draw( false );

            ttPts = 0;
            $('#tblpRODUCTOS').DataTable().column(4).data().each( function ( value, index ) {
                ttPts += parseInt(value);
            } );
            $("#idttPtsFRP").text(ttPts);
            apliAutomatic(ttPts);
    });

    $('#tblpRODUCTOS tbody').on( 'click', 'tr', function () {
        $(this).toggleClass('selected');
    });

     function mensaje(mensaje,clase) {
        var $toastContent = $('<span class="center">'+mensaje+'</span>');
            if (clase == 'error'){
                return Materialize.toast($toastContent, 3500,'rounded error');
            }
            return  Materialize.toast($toastContent, 3500,'rounded');    
    }
    function limpiarTabla (idTabla) {
        idTabla = $(idTabla).DataTable();
        idTabla.destroy();
        idTabla.clear();
        idTabla.draw();
    }
});
function formatNumber(x) {//solo funciona con exteros
        return isNaN(x)?"":x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
function getview(id){
        $('#idviewFRP').openModal();
        $("#vfrpProgress").show();
        $("#vfrpTop,#vfrpTop").hide();
        $('#iconoPrint').hide();
        var form_data = {
            frp: id
        };

        $.ajax({
            url: "getviewFRP",
            type: "post",
            async:true,
            data: form_data,
            success:
            function(data){
                    $("#vfrpProgress").hide();
                    $("#vfrpTop,#vfrpTop").show();

                    var dataJson = JSON.parse(data);
                    console.log(dataJson);

                    var DF="",DP="";
                    if (dataJson.DFactura[0].Anulado == "N"){
                        $('#iconoPrint').show();
                    }
                    $("#spnviewFRP").text(dataJson.top[0].IdFRP);
                    $("#spnviewFecha").text(dataJson.top[0].Fecha);
                    $("#spnviewCodCls").text(dataJson.top[0].IdCliente);
                    $("#spnviewNombreCliente").text(dataJson.top[0].Nombre);

                    for (f=0;f<dataJson.DFactura.length;f++){

                        if( dataJson.DFactura[f].SALDO > 0) {ESTAD ="PARCIAL"}else {ESTAD ="APLICADO"}
                        DF +=   "<tr>" +
                                    "<td>" +dataJson.DFactura[f].Fecha + "</td>" +
                                    "<td>" +dataJson.DFactura[f].Factura+ "</td>" +
                                    "<td>" +formatNumber(dataJson.DFactura[f].Puntos)+ "</td>" +
                                    "<td>" +formatNumber(dataJson.DFactura[f].Faplicado)+ "</td>" +
                                    "<td>" +formatNumber(dataJson.DFactura[f].SALDO)+ "</td>" +
                                    "<td>" +ESTAD+ "</td>" +
                                    "</tr>"
                    }
                    var ttff=0;
                    for (p=0;p<dataJson.DArticulo.length;p++){
                        DP +=   "<tr>" +
                                    "<td>" +dataJson.DArticulo[p].Cantidad + "</td>" +
                                    "<td>" +dataJson.DArticulo[p].IdArticulo+ "</td>" +
                                    "<td>" +dataJson.DArticulo[p].Descripcion+ "</td>" +
                                    "<td>" +formatNumber(dataJson.DArticulo[p].Puntos)+ "</td>" +
                                    "<td>" +formatNumber(dataJson.DArticulo[p].Total)+ "</td>" +
                                "</tr>"

                        ttff += parseInt(dataJson.DArticulo[p].Total);
                    }

                    $("#tblviewDFacturaFRP > tbody").html(DF);
                    $("#tblviewDPremioFRP > tbody").html(DP)
                    $("#spnttFRP").text(ttff);
                }
        });
    }
    $("#idProcederDell").click(function(){
        $("#Dell").closeModal();
        $("#DellRes").openModal();
        id = $("#spnDellFRP").text();
        var form_data = {
            frp: id
        };

        $.ajax({
            url: "delFRP",
            type: "post",
            async:true,
            data: form_data,
            success:
                function(data){
                    console.log(data)
                    if (data != 1){
                        mensaje("SELECCIONE UN CLIENTE PRIMERO","error");
                    } else {
                        window.setTimeout($(location).attr('href',"Frp"), 3000);
                        $("#dellCorrectoFRP").text(id);
                    }
                }
        });
    });
    function dellFrp(id){
        $("#Dell").openModal();
        $("#spnDellFRP").text(id);
    }
    function callUrlPrint(targetURL,id){
        var a = document.createElement('a');
        a.href = targetURL + "/" + $("#" + id ).text();
        a.target = '_blank';
        window.open(a);
    }
    function isVerificar(posicion,fact){
    // alert(posicion+" y "+fact);
        ttFRP = parseInt($("#idttPtsCLsFRP").text());
        ptsFRP = parseInt($("#idttPtsFRP").text());
        var FACTURA   = $('#tblFacturaFRP').DataTable().row(posicion).data().DISPONIBLE;
        
        if($("#CHK"+fact).is(':checked') ) {
            if (ttFRP == 0){
                $("#CHK"+fact).prop('checked', false);
                mensaje("TODOS LOS PUNTOS FUERON APLICADOS","error");
            } else {
                if( ptsFRP == 0){
                    ttFRP = 0;
                    $("#CHK"+fact).prop('checked', false);
                    mensaje("Error: SELECCIONE UN ARTICULO","error");
                } else {
                    if (FACTURA > ttFRP){
                        $("#AP1" + fact).html(ttFRP);
                        $("#EST" + fact).html("PARCIAL");
                        sfactura = FACTURA - ttFRP;
                        $("#DIS" + fact).html(sfactura);
                        ttFRP=0;
                    } else {
                        $("#AP1" + fact).html(FACTURA);
                        ttFRP = ttFRP - FACTURA;
                        $("#DIS" + fact).html("0");
                        $("#EST" + fact).html("APLICADO");
                    }
                }
            }
        } else {
            ttFRP = ttFRP + parseInt($("#AP1" + fact).text());
            $("#AP1" + fact).html("");
            $("#DIS" + fact).html("");
            $("#EST" + fact).html("");
        }
        $("#idttPtsCLsFRP").html(ttFRP);
    }
</script>