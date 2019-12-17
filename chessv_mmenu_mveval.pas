module chessv_mmenu_mveval;
define chessv_mmenu_mveval;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Function CHESSV_MMENU_MVEVAL (ULX, ULY)
*
*   The main menu MOVE EVAL option has just been selected.  This routine is
*   called from inside the main menu event handler.  The main menu event
*   handler will return with the function return value.
*
*   ULX,ULY is the preferred upper left corner within the root drawing
*   window of any subordinate menu.
}
function chessv_mmenu_mveval (         {perform main menu MOVE EVAL operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param;

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}

var
  tp: rend_text_parms_t;               {local copy of text control parameters}
  menu: gui_menu_t;                    {our top level menu}
  name: string_var132_t;               {menu entry name}
  tk: string_var80_t;                  {scratch string token}
  err: string_var8192_t;               {error message string}
  iid: sys_int_machine_t;              {integer menu entry ID}
  i: sys_int_machine_t;                {scratch integer and loop counter}
  fp: real;                            {scratch floating point value}
  sel_p: gui_menent_p_t;               {pointer to selected menu entry}
  parm_p: chess_eval_parm_p_t;         {pointer to one move eval parameter}
  enter: gui_enter_t;                  {user data entry object}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;

label
  loop_top_create, loop_top_select, loop_int, loop_real;

begin
  name.max := size_char(name.str);     {init local var strings}
  tk.max := size_char(tk.str);
  err.max := size_char(err.str);

  chessv_mmenu_mveval := gui_evhan_did_k; {init to all events processed}

  tp := tparm;                         {make copy of official text control params}
  tp.lspace := 1.0;
  rend_set.text_parms^ (tp);

loop_top_create:                       {back here to re-create our top menu}
  gui_menu_create (menu, win_root);    {create our main menu}
  parm_p := eval.parm_p;               {init pointer to first parameter in list}
  iid := 1;                            {make our number for first menu entry}
  while parm_p <> nil do begin         {once for each parameter in the list}
    string_copy (parm_p^.name, name);  {init menu entry string from parameter name}
    {
    *   Set TK to the string representation of the current parameter value.
    }
    tk.len := 0;                       {init to no current value string available}
    case parm_p^.dtype of              {what is this parameter's data type ?}
chess_eval_parmtyp_int_k: begin        {parameter type is INTEGER}
        string_f_int (tk, parm_p^.int_val_p^); {make current value string}
        end;
chess_eval_parmtyp_real_k: begin       {parameter type is REAL}
        string_f_fp_free (tk, parm_p^.real_val_p^, 4);
        end;
      end;                             {end of parameter data type cases}

    string_appendn (name, ' (', 2);    {leading paren around current value}
    string_append (name, tk);          {add current value string}
    string_append1 (name, ')');        {add closing parenthesis}
    gui_menu_ent_add (                 {add this parameter as menu entry}
      menu, name, 0, iid);
    parm_p := parm_p^.next_p;          {advance to next move evaluator parameter}
    iid := iid + 1;                    {make ID number for next menu entry}
    end;                               {back to add this new parm to menu}

  gui_menu_place (menu, ulx - 2, uly); {set menu location within parent window}

loop_top_select:                       {back here to select from our top menu}
  if not gui_menu_select (menu, iid, sel_p) then begin {menu cancelled ?}
    chessv_mmenu_mveval := menu.evhan; {pass back how events were handled}
    return;
    end;
{
*   IID is the ID of the menu entry for the selected parameter.  IID is
*   also the sequential number of the parameter in the EVAL parms chain.
*
*   Now set PARM_P pointing to the descriptor of the selected parameter.
}
  parm_p := eval.parm_p;               {init pointer to first parameter in the list}
  for i := 2 to iid do begin           {once for each entry to advance}
    parm_p := parm_p^.next_p;
    end;
  case parm_p^.dtype of                {what is this parameter's data type ?}
chess_eval_parmtyp_int_k: begin        {parameter type is INTEGER}
      string_f_int (tk, parm_p^.int_val_p^); {make current value string}
      end;
chess_eval_parmtyp_real_k: begin       {parameter type is REAL}
      string_f_fp_free (tk, parm_p^.real_val_p^, 6);
      end;
    end;                               {end of parameter data type cases}

  sys_msg_parm_vstr (msg_parm[1], parm_p^.name);
  gui_enter_create_msg (               {create user data entry object}
    enter,                             {object to create}
    win_play,                          {window to display entry object in}
    tk,                                {initial string for user to edit}
    'chessv_prog', 'enter_move_eval_parm', msg_parm, 1);
  err.len := 0;                        {init to no error string displayed}

  case parm_p^.dtype of                {what is this parameter's data type ?}

chess_eval_parmtyp_int_k: begin        {parameter type is INTEGER}
loop_int:                              {back here on error with value}
      if not gui_enter_get_int (enter, err, i) then begin {cancelled ?}
        goto loop_top_select;          {back to next menu level up}
        end;
      if i > parm_p^.int_max then begin {value too high ?}
        sys_msg_parm_int (msg_parm[1], parm_p^.int_max);
        string_f_message (             {make error string}
          err,                         {resulting string}
          'chessv_prog', 'err_high_int', msg_parm, 1);
        goto loop_int;                 {back to try again}
        end;
      if i < parm_p^.int_min then begin {value too low ?}
        sys_msg_parm_int (msg_parm[1], parm_p^.int_min);
        string_f_message (             {make error string}
          err,                         {resulting string}
          'chessv_prog', 'err_low_int', msg_parm, 1);
        goto loop_int;                 {back to try again}
        end;
      parm_p^.int_val_p^ := i;         {update the value}
      end;                             {end of INTEGER data type case}

chess_eval_parmtyp_real_k: begin       {parameter type is REAL}
loop_real:                             {back here on error with value}
      if not gui_enter_get_fp (enter, err, fp) then begin {cancelled ?}
        goto loop_top_select;          {back to next menu level up}
        end;
      if fp > parm_p^.real_max then begin {value too high ?}
        sys_msg_parm_real (msg_parm[1], parm_p^.real_max);
        string_f_message (             {make error string}
          err,                         {resulting string}
          'chessv_prog', 'err_high_real', msg_parm, 1);
        goto loop_real;                {back to try again}
        end;
      if fp < parm_p^.real_min then begin {value too low ?}
        sys_msg_parm_real (msg_parm[1], parm_p^.real_min);
        string_f_message (             {make error string}
          err,                         {resulting string}
          'chessv_prog', 'err_low_real', msg_parm, 1);
        goto loop_real;                {back to try again}
        end;
      parm_p^.real_val_p^ := fp;       {update the value}
      end;                             {end of REAL data type case}
    end;                               {end of data type cases}
{
*   The value has been successfully updated.
}
  gui_enter_delete (enter);            {delete user entry box}
  gui_menu_delete (menu);              {delete our top menu}
  goto loop_top_create;                {show new value and allow another select}
  end;
