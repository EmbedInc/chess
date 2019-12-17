module chessv_resize;
define chessv_resize;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESSV_RESIZE
*
*   Create or re-create our windows according to the current drawing area
*   size.  All placements within the windows and other state that depends
*   on drawing area size is determined in this routine.
}
procedure chessv_resize;               {adjust state to new window size}

const
  mmenu_high_pix_k = 28;               {max main menu height in pixels}
  mmenu_high_frac_k = 0.059;           {max main menu height as fraction of dim}

var
  xb, yb, di: vect_2d_t;               {2D transform}
  f: real;                             {scratch floating point value}
  i: sys_int_machine_t;                {scratch integer}

begin
  rend_set.enter_rend^;                {make sure we are in graphics mode}

  rend_set.dev_reconfig^;              {look at device parameters and reconfigure}

  rend_get.image_size^ (wind_dx, wind_dy, aspect); {get window size and aspect ratio}

  if wind_bitmap_alloc then begin      {pixel memory allocated in bitmap ?}
    rend_set.dealloc_bitmap^ (wind_bitmap); {deallocate bitmap pixel memory}
    end;
  rend_set.alloc_bitmap^ (             {allocate pixel memory for new window size}
    wind_bitmap,                       {bitmap handle}
    wind_dx, wind_dy,                  {bitmap size in pixels}
    3,                                 {bytes per pixel}
    rend_scope_dev_k);                 {deallocate on device close}
  wind_bitmap_alloc := true;           {indicate that bitmap has pixel memory}
{
*   Set up the 2D transform so that 0,0 is the lower left corner, X is to the
*   right, Y up, and both are in units of pixels.
}
  xb.y := 0.0;                         {fill in static part of 2D transform}
  yb.x := 0.0;

  if aspect >= 1.0
    then begin                         {window is wider than tall}
      xb.x := 2.0 * aspect / wind_dx;
      yb.y := 2.0 / wind_dy;
      di.x := -aspect;
      di.y := -1.0;
      end
    else begin                         {window is taller than wide}
      xb.x := 2.0 / wind_dx;
      yb.y := (2.0 / aspect) / wind_dy;
      di.x := -1.0;
      di.y := -1.0 / aspect;
      end
    ;
  rend_set.xform_2d^ (xb, yb, di);     {set new 2D transform}
{
*   Find sizes and locations of various features.
}
  f := min(                            {main menu height}
    mmenu_high_pix_k,                  {preferred main menu height}
    mmenu_high_frac_k * wind_dy,       {max allowed due to window height}
    mmenu_high_frac_k * wind_dx);      {max allowed due to window width}
  f := round(f);                       {round to nearest whole pixels}
  y_men2 := wind_dy;                   {top of main menu is top of window}
  y_men1 := y_men2 - f;                {set bottom of main menu}

  f := min(2.0, wind_dy * 0.01);       {separating bar height in pixels}
  f := round(f);                       {round to nearest whole pixels}
  y_bar2 := y_men1;                    {bar is immediately below main menu}
  y_bar1 := y_bar2 - f;                {set bottom of separating bar}

  y_main2 := y_bar1;                   {set top of main drawing area}
  y_stat2 := y_men2 - y_men1;          {stat area same height as main menu area}
  y_stat1 := 0.0;                      {status area is at the bottom}
  y_main1 := y_stat2 + (y_bar2 - y_bar1); {leave gap above status area}

  x_bar1 := round(wind_dx * 0.67);     {left edge of bar between play and info areas}
  x_bar2 := x_bar1 + (y_bar2 - y_bar1); {same width as bar below main menu area}
{
*   Set text size, which is derived from main menu height.
}
  tparm.size := max(0.5, (y_men2 - y_men1) * 0.5);
  i := trunc(tparm.size * 0.11);       {whole pixels text vector width}
  i := max(i, 1);                      {always at least one pixel wide}
  tparm.vect_width := i / tparm.size;  {make text vects integer pixels wide}
  rend_set.text_parms^ (tparm);
  thigh := tparm.size * tparm.height;  {save char cell height}
  twide := tparm.size * tparm.width;   {save char cell width}
  lspace := tparm.size * tparm.lspace; {save space between text lines}

  rend_set.exit_rend^;                 {pop back to caller's enter level}

  chessv_makewins;                     {re-create our basic set of GUI windows}
  end;
