{   Public include file for the CHESS library.
}
const
  chess_subsys_k = -38;                {subsystem ID of CHESS library}
  chess_stat_tk_miss_k = 1;            {missing token, fnam, lnum}
  chess_stat_tk_bad_k = 2;             {bad token, fnam, lnum, token}
  chess_stat_tk_ovfl_k = 3;            {too many tokens, fnam, lnum}
  chess_stat_no_evalmov_k = 4;         {no EVAL_MOVE routine installed by EVAL_OPEN}

  chess_eval_min_k = -32767;           {min CHESS_EVAL val, max advantage to black}
  chess_eval_max_k = 32767;            {max CHESS_EVAL val, max advantage to white}

type
  chess_sqr_k_t = (                    {chess square contents, requires flags}
    chess_sqr_empty_k,                 {empty, no piece on this square}
    chess_sqr_wpawn_k,                 {white pawn}
    chess_sqr_wrook_k,                 {white rook}
    chess_sqr_wknight_k,               {white knight}
    chess_sqr_wbishop_k,               {white bishop}
    chess_sqr_wqueen_k,                {white queen}
    chess_sqr_wking_k,                 {white king}
    chess_sqr_bpawn_k,                 {black pawn}
    chess_sqr_brook_k,                 {black rook}
    chess_sqr_bknight_k,               {black knight}
    chess_sqr_bbishop_k,               {black bishop}
    chess_sqr_bqueen_k,                {black queen}
    chess_sqr_bking_k);                {black king}

  chess_sqrflg_k_t = (                 {modifier flags for CHESS_SQR_K_T}
    chess_sqrflg_orig_k,               {piece never moved, in original position}
    chess_sqrflg_pawn2_k);             {pawn just jumped 2 squares last move}
  chess_sqrflg_t = set of chess_sqrflg_k_t;

  chess_square_t = record              {expanded info for one board square}
    piece: chess_sqr_k_t;              {piece on this square}
    flags: chess_sqrflg_t;             {modifier flags for piece ID}
    end;

  chess_pos_p_t = ^chess_pos_t;
  chess_pos_t = record                 {description of one board position}
    prev_p: chess_pos_p_t;             {points to previous position, NIL for none}
    sq: array[0..7, 0..7] of chess_square_t; {near-far, left-right, white point of view}
    nsame: sys_int_machine_t;          {number of positions with no piece changes, 1 at first}
    end;

  chess_move_t = record                {state for generating successive moves}
    pos: chess_pos_t;                  {starting position}
    x, y: sys_int_machine_t;           {coordinates of current move source square}
    kx, ky: sys_int_machine_t;         {coor of moving color's king}
    lx, ly: sys_int_machine_t;         {dest coordinates of last move generated}
    piece: chess_sqr_k_t;              {ID of moved piece}
    next: int8u_t;                     {internal move generator restart condition}
    white: boolean;                    {TRUE if white is moving, FALSE for black}
    king: boolean;                     {TRUE if moving color has a king}
    end;

  chess_cov_t = record                 {info about one piece covering a square}
    x, y: sys_int_machine_t;           {coordinates of piece covering the square}
    end;

  chess_covlist_t = record             {list of pieces covering a square}
    n: sys_int_machine_t;              {number of pieces covering the square}
    cov: array[1..16] of chess_cov_t;  {list of covering pieces, N entries}
    end;

  chess_eval_parmtyp_k_t = (           {the different EVAL parameter data types}
    chess_eval_parmtyp_int_k,          {32 bit signed integer}
    chess_eval_parmtyp_real_k);        {normal system "real" (floating point) value}

  chess_eval_parm_p_t = ^chess_eval_parm_t;
  chess_eval_parm_t = record           {info about one parameter for EVAL routine}
    prev_p: chess_eval_parm_p_t;       {pointer to previous parm, NIL for first}
    next_p: chess_eval_parm_p_t;       {pointer to next parm, NIL for last}
    priv: sys_int_adr_t;               {for private implementation use}
    name: string_var80_t;              {name or description displayed to user}
    dtype: chess_eval_parmtyp_k_t;     {parameter data type}
    case chess_eval_parmtyp_k_t of     {different data for each data type}
chess_eval_parmtyp_int_k: (            {32 bit signed integer}
      int_min: integer32;              {min allowed value}
      int_max: integer32;              {max allowed value}
      int_val_p: ^integer32;           {pointer to the value}
      );
chess_eval_parmtyp_real_k: (           {floating point}
      real_min: real;                  {min allowed value}
      real_max: real;                  {max allowed value}
      real_val_p: ^real;               {pointer to the value}
      );
    end;

  chess_eval_p_t = ^chess_eval_t;
  chess_eval_t = record                {info and handles for evaluation mechanism}
    mem_p: util_mem_context_p_t;       {pointer to private memory context}
    parm_p: chess_eval_parm_p_t;       {pnt to first parms chain entry, NIL if none}
    last_p: chess_eval_parm_p_t;       {pnt to last parms chain entry, NIL if none}
    eval_move_p: ^function (           {function to evaluate a candidate move}
      in      eval_p: chess_eval_p_t;  {pointer to this move evaluator use}
      in      pos: chess_pos_t;        {board position after the move}
      in      whmove: boolean)         {it is now white's move}
      :sys_int_machine_t;              {range CHESS_EVAL_xxx_K, high good for white}
      val_param;
    close_p: ^procedure (              {call to deallocate all EVAL resources}
      in      eval_p: chess_eval_p_t); {pointer to this move evaluator use}
      val_param;
    priv_p: univ_ptr;                  {pointer to private memory}
    end;
{
*
*   Entry points.
}
function chess_cover (                 {check whether square covered at all}
  in      pos: chess_pos_t;            {board position}
  in      cx, cy: sys_int_machine_t;   {coordinates of square to check}
  in      white: boolean)              {color to check for covering the square}
  :boolean;                            {TRUE if square being covered by given color}
  val_param; extern;

procedure chess_cover_list (           {make lists of pieces covering a square}
  in      pos: chess_pos_t;            {board position}
  in      cx, cy: sys_int_machine_t;   {coordinates of square to check}
  out     wlist: chess_covlist_t;      {list of white pieces covering the square}
  out     blist: chess_covlist_t);     {list of black pieces covering the square}
  val_param; extern;

procedure chess_eval_addparm (         {add parm to end of evaluator parameters list}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      dtype: chess_eval_parmtyp_k_t; {data type of the new parameter}
  in      name: string);               {user-visible name, NULL term or blank padded}
  val_param; extern;

procedure chess_eval_close (           {deallocate resources, close move eval use}
  in out  eval: chess_eval_t);         {context for this move evaluator use}
  val_param; extern;

procedure chess_eval_init (            {initialize context and start move evaluator}
  out     eval: chess_eval_t;          {move evaluator context to initialize}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure chess_eval_malloc (          {get private EVAL mem, no individual dealloc}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      size: sys_int_adr_t;         {amount of memory to allocate}
  out     adr: univ_ptr);              {start of new memory region}
  val_param; extern;

procedure chess_eval_open (            {init implementation-specific in EVAL info}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

function chess_move (                  {generate next move from move gen state}
  in out  st: chess_move_t;            {move generator state}
  out     pos: chess_pos_t)            {board position after move}
  :boolean;                            {TRUE move generated, FALSE no move left}
  val_param; extern;

procedure chess_move_init (            {initialize for generating moves from pos}
  in      pos_p: chess_pos_p_t;        {points to position to generated moves from}
  in      white: boolean;              {TRUE for white moving, FALSE for black}
  out     st: chess_move_t);           {returned initialized move generator state}
  val_param; extern;

procedure chess_name_move (            {create name string from a chess move}
  in      st: chess_move_t;            {the move}
  in out  name: univ string_var_arg_t); {returned name string}
  val_param; extern;

procedure chess_name_piecea (          {create chess piece abbreviation letter}
  in      piece: chess_sqr_k_t;        {ID of the chess piece}
  in out  name: univ string_var_arg_t); {returned name string}
  val_param; extern;

procedure chess_name_square (          {create the text name of a chess square}
  in      x, y: sys_int_machine_t;     {coordinates of the square}
  in      white: boolean;              {name from white's point of view}
  in out  name: univ string_var_arg_t); {returned name string}
  val_param; extern;

procedure chess_read_pos (             {read board position from text stream}
  in out  conn: file_conn_t;           {connection to input stream}
  out     pos: chess_pos_t;            {returned board position}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;
