interface ZIF_ZSD_GET_DATA_COCKPIT
  public .


  types:
    VBELN type C length 000010 .
  types:
    POSNR type N length 000006 .
  types:
    PSTYV type C length 000004 .
  types:
    VKORG type C length 000004 .
  types:
    VTEXT type C length 000020 .
  types:
    KUNNR type C length 000010 .
  types:
    NAME1_GP type C length 000035 .
  types:
    PS_PSP_PNR type N length 000008 .
  types:
    PS_POST1 type C length 000040 .
  types:
    WOGXXX type P length 12  decimals 000002 .
  types:
    AD01NOWRT type P length 8  decimals 000002 .
  types:
    WAERK type C length 000005 .
  types:
    begin of ZCKPT_PROJECT_S,
      NUM_COMMANDE type VBELN,
      POSTE_COMMANDE type POSNR,
      TYPE_POSTE type PSTYV,
      DATE_DEBUT type DATS,
      DATE_FIN type DATS,
      ORG_COMM type VKORG,
      ORG_COMM_TEXT type VTEXT,
      NUM_CLIENT type KUNNR,
      CLIENT type NAME1_GP,
      NUM_DOSSIER type PS_PSP_PNR,
      DOSSIER type PS_POST1,
      MONTANT_ORIGIN type WOGXXX,
      MONTANT_FACT type WOGXXX,
      MONTANT_REF type AD01NOWRT,
      MONTANT_OUVERT type WOGXXX,
      DEVISE type WAERK,
    end of ZCKPT_PROJECT_S .
  types:
    ZCKPT_PROJECT_TT               type standard table of ZCKPT_PROJECT_S                with non-unique default key .
  types:
    NAME1 type C length 000030 .
  types:
    MANDT type C length 000003 .
  types:
    SPRAS type C length 000001 .
  types:
    VTXTK type C length 000020 .
  types:
    begin of TVKOT,
      MANDT type MANDT,
      SPRAS type SPRAS,
      VKORG type VKORG,
      VTEXT type VTXTK,
    end of TVKOT .
endinterface.
