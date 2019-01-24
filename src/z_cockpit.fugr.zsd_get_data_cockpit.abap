FUNCTION zsd_get_data_cockpit.
*"----------------------------------------------------------------------
*"*"Interface locale :
*"  IMPORTING
*"     VALUE(I_NUM_COMMANDE) TYPE  VBELN OPTIONAL
*"     VALUE(I_START_DATE) TYPE  DATS OPTIONAL
*"     VALUE(I_END_DATE) TYPE  DATS OPTIONAL
*"     VALUE(I_NUM_DOSSIER) TYPE  PS_PSP_PNR OPTIONAL
*"     VALUE(I_NOM_DOSSIER) TYPE  PS_POST1 OPTIONAL
*"     VALUE(I_NUM_CLIENT) TYPE  KUNNR OPTIONAL
*"     VALUE(I_NOM_CLIENT) TYPE  NAME1 OPTIONAL
*"     VALUE(I_NUM_POSTE) TYPE  POSNR OPTIONAL
*"     VALUE(I_ORG_COMM) TYPE  TVKOT-VTEXT OPTIONAL
*"  EXPORTING
*"     VALUE(IT_PROJECT) TYPE  ZCKPT_PROJECT_TT
*"----------------------------------------------------------------------

  TYPES : BEGIN OF ty_cmd,
            vbeln      TYPE vbak-vbeln, " Numéro de commande
            kunnr      TYPE vbak-kunnr, " Client
            name1      TYPE kna1-name1, " Nom du client
            vkorg      TYPE vbak-vkorg, " Org comm
            vtext      TYPE tvkot-vtext, " Texte orga comm
            posnr      TYPE vbap-posnr, " Numéro de poste
            ps_psp_pnr TYPE vbap-ps_psp_pnr, " Element OTP
            post1      TYPE prps-post1, " Nom du dossier
          END OF ty_cmd.

  DATA : lt_cmd      TYPE TABLE OF ty_cmd,
         ls_cmd      TYPE ty_cmd,
         ls_cmd_tmp  TYPE ty_cmd,
         lt_posnr    TYPE vpkti_tt_posnr,
         lt_item     TYPE vpkti_tt_item,
         ls_item     TYPE vpkti_t_item,
         ls_project  TYPE zckpt_project_s,
         lt_all_item TYPE vpkti_tt_item,
         lr_vbeln    TYPE RANGE OF vbak-vbeln,
         lr_posnr    TYPE RANGE OF vbap-posnr,
         lr_otp      TYPE RANGE OF vbap-ps_psp_pnr,
         lr_otptext  TYPE RANGE OF prps-post1,
         lr_vtext    TYPE RANGE OF tvkot-vtext,
         lr_kunnr    TYPE RANGE OF vbak-kunnr,
         lr_name1    TYPE RANGE OF kna1-name1,
         lr_date     TYPE RANGE OF sy-datum,
         lt_dlia     TYPE TABLE OF ad01dlia,
         lt_all_dlia TYPE TABLE OF ad01dlia.
  CONSTANTS : c_ffprf TYPE vbkd-ffprf VALUE 'ZGIDEN',
              c_x     TYPE c VALUE 'X',
              c_e     TYPE c VALUE 'E',
              c_zcve  TYPE vbak-auart VALUE 'ZCVE'.

  PERFORM fill_range TABLES lr_vbeln
                    USING i_num_commande
                          space.

  PERFORM fill_range TABLES lr_posnr
                    USING i_num_poste
                          space.

  PERFORM fill_range TABLES lr_otp
                   USING i_num_dossier
                         space.

  PERFORM fill_range TABLES lr_otptext
                 USING i_nom_dossier
                       space.

  PERFORM fill_range TABLES lr_kunnr
               USING i_num_client
                     space.

  PERFORM fill_range TABLES lr_name1
             USING i_nom_client
                   space.

  PERFORM fill_range TABLES lr_vtext
           USING i_org_comm
                 space.

  PERFORM fill_range TABLES lr_date
         USING i_start_date
               i_end_date.

* Sélection des commandes pour le dossier
  SELECT vbak~vbeln,
         vbak~kunnr,
         name1,
         vbak~vkorg,
         vtext,
         vbap~posnr,
         vbap~ps_psp_pnr,
         post1
  FROM vbak
  INNER JOIN tvkot
  ON tvkot~vkorg = vbak~vkorg
  AND tvkot~spras = @sy-langu
  INNER JOIN vbap
  ON vbap~vbeln = vbak~vbeln
  INNER JOIN vbkd
  ON vbkd~vbeln = vbak~vbeln
  INNER JOIN kna1
  ON kna1~kunnr = vbak~kunnr
   INNER JOIN prps
  ON prps~pspnr = vbap~ps_psp_pnr
  INTO CORRESPONDING FIELDS OF TABLE @lt_cmd
  WHERE vbak~vbeln IN @lr_vbeln
  AND vbak~auart EQ @c_zcve
  AND vbak~kunnr IN @lr_kunnr
  AND name1 IN @lr_name1
  AND vbap~posnr IN @lr_posnr
  AND vbap~ps_psp_pnr IN @lr_otp
  AND post1 IN @lr_otptext
  AND vtext IN @lr_vtext
  AND audat IN @lr_date
  AND vbkd~ffprf = @c_ffprf.

  LOOP AT lt_cmd INTO ls_cmd.
    APPEND ls_cmd-posnr TO lt_posnr.
    MOVE-CORRESPONDING ls_cmd TO ls_cmd_tmp.
    AT END OF vbeln.
* Récupération par commandes des postes à facturer
      CALL FUNCTION 'VPKDPP_GET_DI_WITH_VALUES'
        EXPORTING
          i_mode             = c_e
          i_vbeln            = ls_cmd-vbeln
          i_date_to          = sy-datum
        TABLES
          it_posnr           = lt_posnr
          et_valitem_di      = lt_item
          et_dlia            = lt_dlia
        EXCEPTIONS
          input_error        = 1
          object_error       = 2
          date_error         = 3
          hierarchy_error    = 4
          dynamic_item_error = 5
          no_data            = 6
          OTHERS             = 7.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty
        NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      LOOP AT lt_item INTO ls_item
                      WHERE flagdi EQ c_x.
        CLEAR ls_project.
        ls_project-num_commande = ls_cmd_tmp-vbeln. " Num commande
        ls_project-poste_commande = ls_item-posnr. " Poste
        ls_project-num_client = ls_cmd_tmp-kunnr. " Nom client
        ls_project-client = ls_cmd_tmp-name1. " Client
        ls_project-devise = ls_item-kwaer. " Devise
        ls_project-date_debut =  i_start_date.
        ls_project-date_fin = i_end_date.
        ls_project-num_dossier = ls_cmd_tmp-ps_psp_pnr. " Dossier
        ls_project-dossier = ls_cmd_tmp-post1. " Dossier
        ls_project-org_comm = ls_cmd_tmp-vkorg.
        ls_project-org_comm_text = ls_cmd_tmp-vtext.
        ls_project-montant_origin = ls_item-so_wogbtr. " Montant origine
        ls_project-montant_fact = ls_item-bi_wogbtr. " Montant facturé
        ls_project-montant_ouvert =   ls_item-so_wogbtr - ls_item-bi_wogbtr - ls_item-ca_wogbtr.
        ls_project-montant_ref = ls_item-ca_wogbtr.
        COLLECT ls_project INTO it_project.
      ENDLOOP.

      REFRESH : lt_posnr,
                lt_item,
                lt_dlia.
    ENDAT.
  ENDLOOP.

ENDFUNCTION.
