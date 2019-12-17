module chessv_init;
define chessv_init;
%include 'chessv2.ins.pas';
define chessv;                         {define common block here}
{
*************************************************************************
*
*   Subroutine CHESSV_INIT
*
*   Perform one-time initialization of the graphics and window state.
}
procedure chessv_init;                 {set up state before first draw}

var
  str: string_var80_t;                 {scratch string}
  stat: sys_err_t;                     {Cognivision completion status code}

label
  opened;

begin
  str.max := size_char(str.str);       {init local var strings}

  util_mem_context_get (               {get mem context for any permanent mem}
    util_top_mem_context,              {parent memory context}
    mem_p);                            {returned pointer to new mem context}
{
*   Start RENDlib.
}
  rend_start;                          {wake up RENDlib}

  string_vstring (str, 'chessv'(0), -1); {try this RENDlib device name first}
  rend_open (str, rendev, stat);       {open main drawing window}
  if not sys_error(stat) then goto opened;

  string_vstring (str, 'screen'(0), -1);
  rend_open (str, rendev, stat);       {open main drawing window}
  if not sys_error(stat) then goto opened;

  string_vstring (str, '*screen*'(0), -1);
  rend_open (str, rendev, stat);       {open main drawing window}
  if not sys_error(stat) then goto opened;

  str.len := 0;                        {try default graphics device}
  rend_open (str, rendev, stat);       {open main drawing window}
  if not sys_error(stat) then goto opened;
  sys_error_abort (stat, '', '', nil, 0);
opened:                                {RENDlib device has been opened}

  rend_set.enter_rend^;                {push one level into graphics mode}

  rend_get.text_parms^ (tparm);        {get default text control parameters}
  tparm.width := 0.72;
  tparm.height := 1.0;
  tparm.slant := 0.0;
  tparm.rot := 0.0;
  tparm.lspace := 0.7;
  tparm.coor_level := rend_space_2d_k;
  tparm.poly := false;
  rend_set.text_parms^ (tparm);        {set our new "base" text control parameters}

  rend_get.poly_parms^ (pparm);        {get default polygon control parameters}
  pparm.subpixel := true;
  rend_set.poly_parms^ (pparm);        {set our new "base" polygon control parms}

  rend_get.vect_parms^ (vparm);        {get default vector control parameters}
  vparm.width := 2.0;
  vparm.poly_level := rend_space_none_k;
  vparm.subpixel := false;
  rend_set.vect_parms^ (vparm);        {set our new "base" vector control parameters}
{
*   Set up software backup bitmap and init some of our common block state.
}
  rend_set.alloc_bitmap_handle^ (      {create handle for our software bitmap}
    rend_scope_dev_k,                  {deallocate handle when device closed}
    wind_bitmap);                      {returned bitmap handle}
  wind_bitmap_alloc := false;          {indicate no pixels allocated for bitmap}
{
*   Set up the interpolants.
}
  rend_set.iterp_bitmap^ (rend_iterp_red_k, wind_bitmap, 0); {connect to bitmap}
  rend_set.iterp_bitmap^ (rend_iterp_grn_k, wind_bitmap, 1);
  rend_set.iterp_bitmap^ (rend_iterp_blu_k, wind_bitmap, 2);

  rend_set.iterp_on^ (rend_iterp_red_k, true); {enable the interpolants}
  rend_set.iterp_on^ (rend_iterp_grn_k, true);
  rend_set.iterp_on^ (rend_iterp_blu_k, true);
{
*   Init other graphics state before the first drawing.
}
  rend_set.min_bits_vis^ (24.0);       {try for high color resolution}

  rend_set.update_mode^ (rend_updmode_buffall_k); {buffer SW updates for speed sake}
{
*   Enable the non-key events.
}
  rend_set.event_req_close^ (true);    {enable CLOSE, CLOSE_USER}
  rend_set.event_req_wiped_resize^ (true); {redraw due to size change}
  rend_set.event_req_wiped_rect^ (true); {redraw due to got corrupted}
  rend_set.event_req_pnt^ (true);      {request pointer motion events}
{
*   Enable key events.
}
  gui_events_init_key;                 {enable keys required by GUI library}

  rend_set.enter_level^ (0);           {make sure we are out of graphics mode}
  windows := false;                    {indicate GUI windows not currently exist}
  end;
