*----------------------------------------------------------------------*
***INCLUDE LZ_COCKPITF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FILL_RANGE
*&---------------------------------------------------------------------*
*& Remplir le range
*&---------------------------------------------------------------------*
FORM fill_range TABLES ft_table
                USING    f_val1
                          f_val2.
  DATA: ls_sel TYPE selopt.

  CONSTANTS : c_eq TYPE selopt-option VALUE 'EQ',
              c_bt TYPE selopt-option VALUE 'BT'.

  CHECK f_val1 IS NOT INITIAL.

  ls_sel-sign = 'I'.

  IF f_val2 IS INITIAL.
    ls_sel-option = c_eq.
  ELSE.
    ls_sel-option = c_bt.
  ENDIF.

  ls_sel-low = f_val1.
  ls_sel-high = f_val2.
  APPEND ls_sel TO ft_table.


ENDFORM.
