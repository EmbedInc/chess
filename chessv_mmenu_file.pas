module chessv_mmenu_file;
define chessv_mmenu_file;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESSV_WRITE_POS (FNAM, STAT)
*
*   Write the current chess position to the file of name FNAM.
}
procedure chessv_write_pos (           {write current chess position to file}
  in      fnam: univ string_var_arg_t; {name of file to write position to}
  out     stat: sys_err_t);            {completion status code}
  val_param; internal;

var
  conn: file_conn_t;                   {connection to output file}
  x, y: sys_int_machine_t;             {chess square coordinate}
  buf: string_var132_t;                {one line output buffer}
  tk: string_var16_t;                  {scratch token}

label
  have_name, err;

begin
  buf.max := size_char(buf.str);       {init local var strings}
  tk.max := size_char(tk.str);

  file_open_write_text (fnam, '.chp', conn, stat); {open the file}
  if sys_error(stat) then return;

  for y := 7 downto 0 do begin         {once for each row}
    buf.len := 0;                      {init the output line to empty}
    for x := 0 to 7 do begin           {accross this row}
      if chess_sqrflg_orig_k in pos.sq[y, x].flags then begin {in original position ?}
        string_vstring (tk, 'or', 2);
        goto have_name;
        end;
      if chess_sqrflg_pawn2_k in pos.sq[y, x].flags then begin {pawn just jumped 2 ?}
        if pos.sq[y, x].piece = chess_sqr_wpawn_k
          then string_vstring (tk, 'w2', 2)
          else string_vstring (tk, 'b2', 2);
        goto have_name;
        end;
      case pos.sq[y, x].piece of       {what piece is on this square ?}
chess_sqr_wpawn_k: string_vstring (tk, 'wp', 2); {white pawn}
chess_sqr_wrook_k: string_vstring (tk, 'wr', 2); {white rook}
chess_sqr_wknight_k: string_vstring (tk, 'wn', 2); {white knight}
chess_sqr_wbishop_k: string_vstring (tk, 'wb', 2); {white bishop}
chess_sqr_wqueen_k: string_vstring (tk, 'wq', 2); {white queen}
chess_sqr_wking_k: string_vstring (tk, 'wk', 2); {white king}
chess_sqr_bpawn_k: string_vstring (tk, 'bp', 2); {black pawn}
chess_sqr_brook_k: string_vstring (tk, 'br', 2); {black rook}
chess_sqr_bknight_k: string_vstring (tk, 'bn', 2); {black knight}
chess_sqr_bbishop_k: string_vstring (tk, 'bb', 2); {black bishop}
chess_sqr_bqueen_k: string_vstring (tk, 'bq', 2); {black queen}
chess_sqr_bking_k: string_vstring (tk, 'bk', 2); {black king}
otherwise
        string_vstring (tk, '--', 2);
        end;
have_name:                             {TK is name for contents of this square}
      if buf.len > 0 then begin        {this is not first token in BUF ?}
        string_append1 (buf, ' ');
        end;
      string_append (buf, tk);         {append name for this square to BUF}
      end;                             {back for next square in this row}
    file_write_text (buf, conn, stat); {write line for this row to the output file}
    if sys_error(stat) then goto err;
    end;                               {back for next row towards black}

  buf.len := 0;                        {leave a blank line after board image}
  file_write_text (buf, conn, stat);
  if sys_error(stat) then goto err;

  if lastmove then begin               {there is info about the last move made ?}
    string_vstring (buf, 'LMOVE '(0), -1);
    string_f_int (tk, move_fx);
    string_append (buf, tk);
    string_append1 (buf, ' ');
    string_f_int (tk, move_fy);
    string_append (buf, tk);
    string_append1 (buf, ' ');
    string_f_int (tk, move_tx);
    string_append (buf, tk);
    string_append1 (buf, ' ');
    string_f_int (tk, move_ty);
    string_append (buf, tk);
    file_write_text (buf, conn, stat);
    if sys_error(stat) then goto err;
    end;

  string_vstring (buf, 'MOVE '(0), -1);
  if whmove
    then string_append1 (buf, 'w')
    else string_append1 (buf, 'b');
  file_write_text (buf, conn, stat);
  if sys_error(stat) then goto err;

  string_vstring (buf, 'VIEW '(0), -1);
  if view_white
    then string_append1 (buf, 'w')
    else string_append1 (buf, 'b');
  file_write_text (buf, conn, stat);
  if sys_error(stat) then goto err;

  string_vstring (buf, 'WHITE '(0), -1);
  case playerw of
player_user_k: string_appends (buf, 'user'(0));
player_comp_k: string_appends (buf, 'comp'(0));
player_server_k: string_appends (buf, 'server'(0));
player_client_k: string_appends (buf, 'client'(0));
    end;
  if buf.len > 6 then begin
    file_write_text (buf, conn, stat);
    if sys_error(stat) then goto err;
    end;

  string_vstring (buf, 'BLACK '(0), -1);
  case playerb of
player_user_k: string_appends (buf, 'user'(0));
player_comp_k: string_appends (buf, 'comp'(0));
player_server_k: string_appends (buf, 'server'(0));
player_client_k: string_appends (buf, 'client'(0));
    end;
  if buf.len > 6 then begin
    file_write_text (buf, conn, stat);
    if sys_error(stat) then goto err;
    end;

  file_close (conn);                   {close the output file}
  return;

err:                                   {error, STAT set, output file open}
  file_close (conn);
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_READ_POS (FNAM, STAT)
*
*   Read a new chess position from the file of name FNAM.  No state is
*   altered if STAT is returned indicating an error.  If successful,
*   the program mode will be switched to PAUSE.
}
procedure chessv_read_pos (            {read new chess position from file}
  in      fnam: univ string_var_arg_t; {name of file to read position from}
  out     stat: sys_err_t);            {completion status code}
  val_param; internal;

var
  conn: file_conn_t;                   {connection to input file}
  pick: sys_int_machine_t;             {number of token picked from list}
  buf: string_var132_t;                {one line input buffer}
  p: string_index_t;                   {BUF parse index}
  tk: string_var16_t;                  {token parsed from BUF}
  ps: chess_pos_t;                     {new chess position}
  fx, fy, tx, ty: sys_int_machine_t;   {from/to for last move}
  plw, plb: player_k_t;                {player IDs}
  plw_set, plb_set: boolean;           {TRUE if on player IDs explicitly set}
  lmove: boolean;                      {TRUE if last move from/to available}
  whm: boolean;                        {TRUE for white's move next}
  vw: boolean;                         {TRUE if view board from white's side}

label
  loop_line, eof, err_parm, err_at_line;
{
********************
*
*   Internal function GET_PLAYER (PL)
*
*   Parse the next BUF token as a player ID and return the result in PL.
}
function get_player (                  {get player ID}
  out     pl: player_k_t)              {returned player ID}
  :boolean;                            {TRUE on success (no error)}
  internal;

var
  tk: string_var16_t;                  {token parsed from BUF}

begin
  tk.max := size_char(tk.str);         {init local var string}

  get_player := false;                 {init to not completed successfully}

  string_token (buf, p, tk, stat);
  if sys_error(stat) then return;
  string_upcase (tk);
  string_tkpick80 (tk,
    'USER COMP SERVER CLIENT', pick);
  case pick of
1:  pl := player_user_k;
2:  pl := player_comp_k;
3:  pl := player_server_k;
4:  pl := player_client_k;
otherwise
    return;
    end;
  get_player := true;                  {indicate success}
  end;
{
********************
*
*   Start of main routine of CHESSV_READ_POS.
}
begin
  buf.max := size_char(buf.str);       {init local var strings}
  tk.max := size_char(tk.str);

  file_open_read_text (fnam, '.chp', conn, stat);
  if sys_error(stat) then return;

  lmove := false;                      {init to no last move info available}
  whm := whmove;                       {init who's move to current state}
  vw := view_white;                    {init to preserve current view of board}
  plw_set := false;
  plb_set := false;

  chess_read_pos (conn, ps, stat);     {read raw position of pieces}
  if sys_error(stat) then return;

loop_line:                             {back here each new line from the file}
  file_read_text (conn, buf, stat);    {read next line from the input file}
  if file_eof(stat) then goto eof;     {hit end of input file ?}
  if sys_error(stat) then return;
  string_unpad (buf);                  {delete trailing spaces}
  if buf.len <= 0 then goto loop_line; {ignore blank lines}
  p := 1;                              {init BUF parse index}
  string_token (buf, p, tk, stat);     {get command name token}
  if sys_error(stat) then begin
    sys_stat_set (chessv_subsys_k, chessv_stat_err_cmdget_k, stat);
    goto err_at_line;
    end;
  string_upcase (tk);                  {make command name upper case}
  string_tkpick80 (tk,
    'LMOVE MOVE VIEW WHITE BLACK',
    pick);
  case pick of                         {which command is it ?}
{
*   LMOVE fx fy tx ty
}
1: begin
  string_token_int (buf, p, fx, stat);
  if sys_error(stat) then goto err_parm;
  string_token_int (buf, p, fy, stat);
  if sys_error(stat) then goto err_parm;
  string_token_int (buf, p, tx, stat);
  if sys_error(stat) then goto err_parm;
  string_token_int (buf, p, ty, stat);
  if sys_error(stat) then goto err_parm;
  lmove := true;
  end;
{
*   MOVE (w | b)
}
2: begin
  string_token (buf, p, tk, stat);
  if sys_error(stat) then goto err_parm;
  string_upcase (tk);
  string_tkpick80 (tk, 'W B', pick);
  case pick of
1:  whm := true;
2:  whm := false;
otherwise
    goto err_parm;
    end;
  end;
{
*   VIEW (w | b)
}
3: begin
  string_token (buf, p, tk, stat);
  if sys_error(stat) then goto err_parm;
  string_upcase (tk);
  string_tkpick80 (tk, 'W B', pick);
  case pick of
1:  vw := true;
2:  vw := false;
otherwise
    goto err_parm;
    end;
  end;
{
*   WHITE <player ID>
}
4: begin
  if not get_player (plw) then goto err_parm;
  plw_set := true;
  end;
{
*   BLACK <player ID>
}
5: begin
  if not get_player (plb) then goto err_parm;
  plb_set := true;
  end;
{
*   Unrecognized command name.
}
otherwise
    sys_stat_set (chessv_subsys_k, chessv_stat_cmd_bad_k, stat);
    sys_stat_parm_vstr (tk, stat);
    goto err_at_line;
    end;

  string_token (buf, p, tk, stat);     {try to get another token from the this line}
  if not sys_error(stat) then begin    {found extra token that shouldn't be there ?}
    sys_stat_set (chessv_subsys_k, chessv_stat_tkextra_k, stat);
    goto err_at_line;
    end;
  goto loop_line;                      {back to process next line from input file}
{
*   The end of the input file has been encountered.
}
eof:
  file_close (conn);                   {close the input file}

  if mode = mode_play_k then begin     {suspend play in case automatic move next}
    chessv_setmode (mode_pause_k);
    end;
  pos := ps;                           {update to new position}
  lastmove := lmove;                   {indicate whether we have last move info}
  move_fx := fx;                       {set last move from/to info}
  move_fy := fy;
  move_tx := tx;
  move_ty := ty;
  nlmove := 0;                         {delete contemplated moves list}
  if plw_set then begin
    playerw := plw;
    end;
  if plb_set then begin
    playerb := plb;
    end;
  view_white := vw;
  gui_win_draw_all (win_info);         {refresh info window with new content}
  whmove := whm;                       {indicate who's move it is now}
  chessv_event_newpos;                 {indicate chess position has changed}
  case mode of
mode_play_k,
mode_pause_k: begin
      chessv_event_move;               {have curr player make move, if appropriate}
      end;
    end;
  return;                              {normal return without error}

err_parm:                              {parameter error on the current line}
  sys_stat_set (chessv_subsys_k, chessv_stat_parm_bad_k, stat);

err_at_line:                           {STAT set, add FNAM, LNUM}
  sys_stat_parm_vstr (conn.tnam, stat);
  sys_stat_parm_int (conn.lnum, stat);
  file_close (conn);
  end;
{
********************************************************************************
*
*   Function CHESSV_MMENU_FILE (ULX, ULY, ABTREE)
*
*   The main menu FILE option has just been selected.  This routine is called
*   from inside the main menu event handler.  The main menu event handler will
*   return with the function return value.
*
*   ULX,ULY is the preferred upper left corner within the root drawing
*   window of any subordinate menu.
*
*   ABTREE is returned TRUE unlrdd it is known that the whole menu tree
*   should not be aborted.
}
function chessv_mmenu_file (           {perform main menu FILE operation}
  in      ulx, uly: real;              {preferred sub menu UL in root window}
  out     abtree: boolean)             {abort the whole menu tree}
  :gui_evhan_k_t;                      {events handled indication}
  val_param;

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}

var
  tp: rend_text_parms_t;               {local copy of text control parameters}
  menu: gui_menu_t;                    {our top level menu}
  mmsg: gui_mmsg_t;                    {menu entries message object}
  fnam: string_treename_t;             {file name}
  name: string_treename_t;             {scratch name string}
  shcut: string_index_t;               {index of shortcut key within entry name}
  iid: sys_int_machine_t;              {integer menu entry ID}
  sel_p: gui_menent_p_t;               {pointer to selected menu entry}
  ent: gui_enter_t;                    {string entry object}
  str: string_var80_t;                 {scratch string}
  dir: string_treename_t;              {treename of dir where chess pos files live}
  flist: string_list_t;                {list of pre existing chess file gnams}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status code}

label
  loop_select, done_select, leave, abort;
{
********************
*
*   Subroutine LIST_FILES
*   This routine is local to CHESSV_MMENU_FILE
*
*   Create the list of previously existing chess files in FLIST.  FLIST is
*   assumed to be uninitialized before this call.  FLIST will contain the
*   the generic leafnames of chess position files in the directory
*   indicated by DIR.
}
procedure list_files;

var
  finfo: file_info_t;                  {info about a file}
  fnam: string_leafname_t;             {scratch file name}
  gnam: string_leafname_t;             {generic file name with suffix removed}
  conn: file_conn_t;                   {connection to directory}
  stat: sys_err_t;                     {completion status code}

label
  loop_ent, done;

begin
  fnam.max := size_char(fnam.str);     {init local var strings}
  gnam.max := size_char(gnam.str);

  string_list_init (flist, util_top_mem_context); {initialize the list}
  flist.deallocable := false;          {won't individually deallocate new mem}

  file_open_read_dir (dir, conn, stat); {open directory for reading list of files}
  if sys_error(stat) then return;      {leave list empty on problems}

loop_ent:                              {back here to get each new directory entry}
  file_read_dir (                      {get next directory entry name}
    conn,                              {connection to directory}
    [file_iflag_type_k],               {additional info requested beyond name}
    fnam,                              {returned file name}
    finfo,                             {additional info about the file}
    stat);
  if file_eof(stat) then goto done;    {hit end of directory}
  if sys_stat_match (                  {skip this file if not got all info}
      file_subsys_k, file_stat_info_partial_k, stat)
    then goto loop_ent;
  if sys_error(stat) then goto done;   {quit on any other hard error}
  if finfo.ftype <> file_type_data_k   {this is not a regular data file ?}
    then goto loop_ent;

  string_fnam_unextend (fnam, '.chp'(0), gnam); {try to remove chess file suffix}
  if gnam.len = fnam.len then goto loop_ent; {this file doesn't have chess suffix ?}

  flist.size := gnam.len;              {set length for new string list entry}
  string_list_line_add (flist);        {create new string list entry}
  string_copy (gnam, flist.str_p^);    {copy generic name into new list entry}
  goto loop_ent;                       {back to do next directory entry}

done:                                  {done reading the directory}
  file_close (conn);                   {close connection to the directory}
  string_list_sort (                   {sort the list of file names}
    flist,                             {the list to sort}
    []);                               {additional sort control flags}
  end;
{
********************
*
*   Local subroutine SELECT_FILE (FNAM)
*   This subroutine is local to CHESSV_MMENU_FILE.
*
*   Allow the user to pick from the list of previously existing chess
*   position files.  The function returns TRUE if a selection was made,
*   and FALSE if the selection was cancelled.
*
*   The new menu will be drawn stemming from the selected top level menu
*   entry.  SEL_P is assumed to be pointing to the selected top level menu
*   entry.
}
function select_file (                 {select from list of existing chess pos files}
  in out  fnam: string_treename_t)     {pathname of selected file}
  :boolean;                            {TRUE if selection made, FALSE if cancelled}
  val_param;

var
  menu2: gui_menu_t;                   {menu with file name choices}
  id2: sys_int_machine_t;              {ID of selected menu entry}
  sel2_p: gui_menent_p_t;              {pointer to selected menu entry}
  lnam: string_leafname_t;             {leafname of selected file}

begin
  lnam.max := size_char(lnam.str);     {init local var string}

  select_file := false;                {init to selection was aborted}
  gui_menu_create (menu2, win_root);   {create menu for the file names}
  menu2.flags := menu2.flags + [
    gui_menflag_pickdel_k];            {delete menu when an entry is picked}

  string_list_pos_abs (flist, 1);      {go to first list entry}
  while flist.str_p <> nil do begin    {once for each entry in the list}
    gui_menu_ent_add (menu2, flist.str_p^, 0, flist.curr); {add this name to menu}
    string_list_pos_rel (flist, 1);    {advance to next list entry}
    end;

  gui_menu_place (menu2,               {set location of new menu}
    menu.win.rect.x + sel_p^.xr,
    menu.win.rect.y + sel_p^.yt + 2.0);
  if not gui_menu_select (menu2, id2, sel2_p) then begin {menu cancelled ?}
    abtree := id2 = -1;                {abort the whole menu tree ?}
    return;
    end;

  string_list_pos_abs (flist, id2);    {go to list pos for selected menu entry}
  string_fnam_extend (flist.str_p^, '.chp'(0), lnam); {make full leaf name}
  string_pathname_join (dir, lnam, fnam); {make full pathname and pass it back}
  select_file := true;                 {indicate a selection was made}
  end;
{
********************
*
*   Start of CHESSV_MMENU_FILE.
}
begin
  name.max := size_char(name.str);     {init local var strings}
  str.max := size_char(str.str);
  dir.max := size_char(dir.str);
  fnam.max := size_char(fnam.str);

  sys_cognivis_dir ('progs/chess', dir); {get dir name where chess files kept}
  list_files;                          {make list of previously existing chess files}

  chessv_mmenu_file := gui_evhan_did_k; {init to all events processed}

  tp := tparm;                         {make copy of official text control params}
  tp.lspace := 1.0;
  rend_set.text_parms^ (tp);

  gui_menu_create (menu, win_root);    {create our main menu}
  gui_mmsg_init (                      {init for reading menu entries from message}
    mmsg, 'chessv_prog', 'menu_file', nil, 0);
  while gui_mmsg_next (mmsg, name, shcut, iid) do begin {once for each entry}
    gui_menu_ent_add (menu, name, shcut, iid); {add this entry to menu}
    case iid of                        {which menu entry is this ?}
1:    begin                            {LOAD FROM}
        if flist.n <= 0 then begin     {no files exist ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
2:    begin                            {DELETE}
        if flist.n <= 0 then begin     {no files exist ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
      end;                             {end of which menu entry cases}
    end;                               {back to add next entry to the menu}
  gui_mmsg_close (mmsg);               {done reading menu entries message}
  gui_menu_place (menu, ulx - 2, uly); {set menu location within parent window}

loop_select:                           {back here to do another top select}
  abtree := true;                      {init to abort whole menu tree when done}
  if not gui_menu_select (menu, iid, sel_p) then begin {menu cancelled ?}
    chessv_mmenu_file := menu.evhan;   {pass back how events were handled}
    abtree := iid = -1;                {abort the whole menu tree ?}
    goto abort;
    end;
  case iid of
{
**********
*
*   FILE > SAVE AS
}
0: begin
  str.len := 0;
  gui_enter_create_msg (               {create object for getting string from user}
    ent,                               {object to create}
    win_root,                          {parent window}
    str,                               {seed string}
    'chessv_prog', 'enter_fnam_saveas', nil, 0); {prompt message}
  if not gui_enter_get (ent, str, name) then begin {cancelled ?}
    goto leave;
    end;
  gui_enter_delete (ent);              {delete the string entry object}

  string_pathname_join (dir, name, fnam); {make pathname}

  chessv_write_pos (fnam, stat);       {write the chess position to the file}
  if sys_error(stat) then begin
    sys_msg_parm_vstr (msg_parm[1], fnam);
    discard( gui_message_msg_stat (    {display error message, wait for confirm}
      win_root,                        {parent window for message dialog}
      gui_msgtype_err_k,               {message type}
      stat,
      'chessv_prog', 'err_write_pos_file', msg_parm, 1) );
    end;
  end;
{
**********
*
*   FILE > LOAD FROM
}
1: begin
  if not select_file (name)            {get user file selection from list}
    then goto done_select;             {user cancelled file selection}

  chessv_read_pos (name, stat);        {read new chess position from file}
  if sys_error(stat) then begin
    sys_msg_parm_vstr (msg_parm[1], name);
    discard( gui_message_msg_stat (    {display error message, wait for confirm}
      win_root,                        {parent window for message dialog}
      gui_msgtype_err_k,               {message type}
      stat,
      'chessv_prog', 'err_read_pos_file', msg_parm, 1) );
    end;
  chessv_hist_init;                    {init history list to new position}
  end;
{
**********
*
*   FILE > DELETE
}
2: begin
  if not select_file (name)            {get user file selection from list}
    then goto done_select;             {user cancelled file selection}

  file_delete_name (name, stat);       {delete the file}
  if sys_error(stat) then begin
    sys_msg_parm_vstr (msg_parm[1], name);
    discard( gui_message_msg_stat (    {display error message, wait for confirm}
      win_root,                        {parent window for message dialog}
      gui_msgtype_err_k,               {message type}
      stat,
      '', '', nil, 0) );
    end;
  end;
{
**********
}
    end;                               {end of main menu selection cases}
done_select:
  if not abtree then goto loop_select; {back for another try ?}

leave:
  gui_menu_delete (menu);              {erase and delete main menu}
abort:
  string_list_kill (flist);            {deallocate the chess files list}
  end;
