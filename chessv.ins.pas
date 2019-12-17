{   Public include file for the CHESSV program.
}
const
  chessv_subsys_k = -39;               {CHESSV subsystem ID}
  chessv_stat_err_cmdget_k = 1;        {error getting command name in file}
  chessv_stat_parm_bad_k = 2;          {bad parameter for command from file}
  chessv_stat_cmd_bad_k = 3;           {unrecognized command from file}
  chessv_stat_tkextra_k = 4;           {extra token on line from file}

  maxmoves_k = 150;                    {max moves can store state for}

type
  mode_k_t = (                         {overall program mode}
    mode_play_k,                       {play a game}
    mode_edit_k,                       {edit a chess position}
    mode_pause_k);                     {play suspended, clock stops running}

  info_k_t = (                         {what to display in the info window}
    info_compeval_k,                   {evaluations for last computer move}
    info_hist_k);                      {history list}

  player_k_t = (                       {ID of player for a particular side}
    player_user_k,                     {player is the user}
    player_comp_k,                     {player is the computer}
    player_server_k,                   {moves received from client to our server}
    player_client_k);                  {moves received as client to another server}

  evtype_k_t = sys_int_machine_t (     {I1 values for our private APP events}
    evtype_move_white_k,               {it is now white's move}
    evtype_move_black_k,               {it is now black's move}
    evtype_move_k,                     {have current player do a move}
    evtype_new_pos_k,                  {chess position POS has been changed}
    evtype_new_lmoves_k,               {new list of contemplated moves}
    evtype_new_hist_k,                 {history list changed}
    evtype_hist_k);                    {switch to new history list entry}

  move_t = record                      {info kept about one move}
    val: sys_int_machine_t;            {evaluation of this move}
    name: string_var16_t;              {name for this move}
    pos: chess_pos_t;                  {chess position after the move}
    fx, fy: sys_int_machine_t;         {move source coordinates}
    tx, ty: sys_int_machine_t;         {move destination coordinates}
    end;
  move_p_t = ^move_t;

  hist_ent_p_t = ^hist_ent_t;
  hist_ent_t = record                  {one entry in moves history list}
    prev_p: hist_ent_p_t;              {points to previous history list entry}
    next_p: hist_ent_p_t;              {points to next history list entry}
    pos: chess_pos_t;                  {board position}
    fx, fy: sys_int_machine_t;         {last move source coordinates}
    tx, ty: sys_int_machine_t;         {last move destination coordinates}
    lastmove: boolean;                 {TRUE if last move info valid}
    whmove: boolean;                   {TRUE if it is now white's move}
    end;

var (chessv)
{
*   State related to the windows and graphics.
}
  mem_p: util_mem_context_p_t;         {mem context pnt for our static memory}
  mem_hist_p: util_mem_context_p_t;    {mem context pnt for history list}
  rendev: rend_dev_id_t;               {RENDlib device ID}
  tparm: rend_text_parms_t;            {our base text control parameters}
  thigh: real;                         {resulting char cell height from TPARM}
  twide: real;                         {resulting char cell width from TPARM}
  lspace: real;                        {resulting gap between lines from TPARM}
  pparm: rend_poly_parms_t;            {our base polygon control parameters}
  vparm: rend_vect_parms_t;            {our base vector control parameters}
  wind_bitmap: rend_bitmap_handle_t;   {handle to bitmap for main drawing window}
  wind_bitmap_alloc: boolean;          {TRUE if WIND_BITMAP has pixels allocated}
  wind_dx, wind_dy: sys_int_machine_t; {main drawing window size in pixels}
  aspect: real;                        {drawing device width/height aspect ratio}
  win_root: gui_win_t;                 {our root GUI window}
  win_play: gui_win_t;                 {window for game board play area}
  win_board: gui_win_t;                {window for just the chess board and contents}
  win_info: gui_win_t;                 {window for general information area}
  win_stat: gui_win_t;                 {window for window status bar}
  windows: boolean;                    {TRUE if our base GUI window set exists}
{
*   Various locations within the windows in root window coordinates.
}
  y_men1, y_men2: real;                {bottom/top of main window menu}
  y_bar1, y_bar2: real;                {bot/top of main menu separating bar}
  y_main1, y_main2: real;              {bot/top of main drawing area}
  y_stat1, y_stat2: real;              {bot/top of window status area}
  x_bar1, x_bar2: real;                {lft/rit of bar between main window areas}
  dsquare: real;                       {width/height of one chess square}
{
*   State related to the chess game and position.
}
  hist_start_p: hist_ent_p_t;          {points to first history list entry}
  hist_p: hist_ent_p_t;                {points to current history list entry}
  hist_free_p: hist_ent_p_t;           {pnt to forward linked free hist entries}
  pos: chess_pos_t;                    {current chess position to display}
  move_fx, move_fy: sys_int_machine_t; {square last moved from}
  move_tx, move_ty: sys_int_machine_t; {square last moved to}
  lmoves:                              {list of moves contemplated}
    array[1..maxmoves_k] of move_t;
  lmoves_p_ar:                         {pointers to moves in sorted order}
    array[1..maxmoves_k] of move_p_t;
  nlmove: sys_int_machine_t;           {number of moves in LMOVES and LMOVES_P_AR}
  nlmove_lhist: sys_int_machine_t;     {NLMOVE for last history entry}
  lmove: sys_int_machine_t;            {1-N LMOVES_P_AR index of chosen move}
  lmove_sec: real;                     {seconds used to evaluate all moves}
  mode: mode_k_t;                      {overall program mode}
  info_disp: info_k_t;                 {selects what to display in info window}
  playerw, playerb: player_k_t;        {ID for each of the players}
  eval: chess_eval_t;                  {move evaluator context}
  lastmove: boolean;                   {TRUE if there is a last move to show}
  view_white: boolean;                 {display position from white's point of view}
  whmove: boolean;                     {TRUE if white's move, FALSE for black's}
  umove: boolean;                      {it is the user's move}
{
*   Other state.
}
  rand: math_rand_seed_t;              {random number generator seed}
{
*   Entry point declarations.
}
procedure chessv_coor_sqr (            {find chess square containing a coordinate}
  in      rx, ry: real;                {RENDlib raw device coordinate}
  out     sqx, sqy: sys_int_machine_t); {chess square coor, 0-7 if within board}
  val_param; extern;

procedure chessv_coorp_sqr (           {find chess square from PLAY window coor}
  in      px, py: real;                {PLAY window coordinate}
  out     sqx, sqy: sys_int_machine_t); {chess square coor, 0-7 if within board}
  val_param; extern;

function chessv_drag (                 {perform a pointer rubber band drag operation}
  in      startx, starty: real;        {RENDlib coordinates of drag start}
  out     endx, endy: real)            {final RENDlib end of drag coordinates}
  :boolean;                            {TRUE if drag confirmed, not cancelled}
  val_param; extern;

procedure chessv_err_abort (           {display message and abort on error}
  in      stat: sys_err_t;             {error status code to test}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

procedure chessv_event_hist;           {generate event for at new history entry}
  val_param; extern;

procedure chessv_event_lmoves;         {generate event for new computer moves list}
  val_param; extern;

procedure chessv_event_move;           {generate event for curr player to make move}
  val_param; extern;

procedure chessv_event_newpos;         {generate event for new chess position}
  val_param; extern;

procedure chessv_event_newhist;        {generate event for change history list}
  val_param; extern;

procedure chessv_event_newmove;        {generate event for other player's move}
  val_param; extern;

procedure chessv_event_nextmove;       {generate events for done with curr move}
  val_param; extern;

procedure chessv_hist_add;             {add current position to history list}
  extern;

procedure chessv_hist_get;             {get current position from curr hist entry}
  extern;

procedure chessv_hist_init;            {init history list from current position}
  extern;

procedure chessv_hist_set;             {set curr history entry from curr position}
  extern;

procedure chessv_hist_trunc;           {truncate history list after curr position}
  extern;

procedure chessv_init;                 {set up state before first draw}
  extern;

procedure chessv_makewins;             {create our basic set of GUI windows}
  extern;

procedure chessv_mmenu_init;           {set up state for main menu}
  extern;

function chessv_mmenu_action (         {perform main menu ACTION operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param; extern;

function chessv_mmenu_file (           {perform main menu FILE operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param; extern;

function chessv_mmenu_plrs (           {perform main menu PLAYERS operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param; extern;

function chessv_mmenu_mveval (         {perform main menu MOVE EVAL operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param; extern;

function chessv_mmenu_view (           {perform main menu VIEW operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param; extern;

procedure chessv_move_client;          {get next move from server we are client to}
  val_param; extern;

procedure chessv_move_comp;            {have the computer do the next move}
  val_param; extern;

procedure chessv_move_server;          {get next move from client to our server}
  val_param; extern;

procedure chessv_move_user;            {get the next move from the user}
  val_param; extern;

procedure chessv_piece_draw (          {draw a chess piece into 0,0 to 1,1 square}
  in      onsqr: chess_square_t);      {ID of what is on the square to draw}
  val_param; extern;

function chessv_pos_same (             {check board positions for same pieces}
  in      pos1, pos2: chess_pos_t)     {board positions to compare}
  :boolean;                            {TRUE if same pieces in same locations}
  val_param; extern;

procedure chessv_pos_start (           {create starting chess position}
  out     pos: chess_pos_t);           {chess position to initialize}
  val_param; extern;

procedure chessv_resize;               {adjust state to new window size}
  extern;

procedure chessv_run;                  {run program after one-time initialization}
  extern;

procedure chessv_setmode (             {set new overall program mode}
  in      newmode: mode_k_t);          {new mode to set to}
  val_param; extern;

procedure chessv_sqr_coor (            {make RENDlib coor of chess square center}
  in      sqx, sqy: sys_int_machine_t; {chess square coor, 0-7 if within board}
  out     rx, ry: real);               {RENDlib coor of chess square center}
  val_param; extern;

procedure chessv_sqr_coorp (           {make PLAY window coor of chess square center}
  in      sqx, sqy: sys_int_machine_t; {chess square coor, 0-7 if within board}
  out     px, py: real);               {PLAY window coor of chess square center}
  val_param; extern;

procedure chessv_stat_msg (            {set status string from a message}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

procedure chessv_stat_str (            {set string to display in status window}
  in      str: univ string_var_arg_t); {string to be displayed}
  val_param; extern;

procedure chessv_win_board_init;       {init contents of chess board window}
  extern;

procedure chessv_win_info_init;        {init contents of info area window}
  extern;

procedure chessv_win_play_init;        {init contents of play area window}
  extern;

procedure chessv_win_root_init;        {create and init root GUI window}
  extern;

procedure chessv_win_stat_init;        {init contents of status bar window}
  extern;

function roundown (                    {round to integer toward minus infinity}
  in      f: real)                     {input value to round}
  :sys_int_machine_t;                  {returned integer}
  val_param; extern;
