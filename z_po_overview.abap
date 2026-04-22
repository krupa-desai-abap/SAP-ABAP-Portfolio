*&---------------------------------------------------------------------*
*& Report Z_PO_OVERVIEW
*&---------------------------------------------------------------------*
*& Purpose: Displays a Purchase Order Overview using modern SAP
*&          HANA Open SQL syntax and Object-Oriented ALV (CL_SALV_TABLE).
*&---------------------------------------------------------------------*
REPORT z_po_overview.

TABLES: ekko, ekpo.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  " Using ranges so the user has flexibility to filter.
  " AEDAT is mandatory to prevent the report from pulling whole data.

  " Header Level Filters
  SELECT-OPTIONS: s_aedat FOR ekko-aedat OBLIGATORY,   " Date
                  s_ebeln FOR ekko-ebeln,              " PO Number
                  s_lifnr FOR ekko-lifnr.              " Vendor Number

  " Item Level Filters
  SELECT-OPTIONS: s_matnr FOR ekpo-matnr,              " Material Number
                  s_werks FOR ekpo-werks.              " Plant

SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Data Retrieval (Code-to-Data Paradigm on HANA)
*----------------------------------------------------------------------*
SELECT a~ebeln,
       a~aedat,
       a~ernam,
       a~lifnr,
       b~name1,
       b~ort01,
       c~ebelp,
       c~matnr,
       c~txz01,
       c~menge,
       c~meins,
       c~netpr,
       c~werks
  FROM ekko AS a 
  INNER JOIN ekpo AS c ON a~ebeln = c~ebeln
  INNER JOIN lfa1 AS b ON a~lifnr = b~lifnr 
  INTO TABLE @DATA(it_po_data) 
  WHERE a~ebeln IN @s_ebeln 
      AND a~aedat IN @s_aedat 
      AND a~lifnr IN @s_lifnr 
      AND c~matnr IN @s_matnr 
      AND c~werks IN @s_werks.

*----------------------------------------------------------------------*
* ALV Display (Object-Oriented Approach)
*----------------------------------------------------------------------*
IF it_po_data IS NOT INITIAL.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = DATA(lo_alv)
        CHANGING
          t_table      = it_po_data ).
      
      lo_alv->get_functions( )->set_all( abap_true ).
      lo_alv->get_columns( )->set_optimize( abap_true ).
      lo_alv->display( ).
      
    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ELSE.
  MESSAGE 'No data found for these selection criteria.' TYPE 'S' DISPLAY LIKE 'E'.

ENDIF.
