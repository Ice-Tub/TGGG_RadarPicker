# picking_isochrones

To pick layers in airborne radar data you need to run 'pick_manually.m'.

Data:

The raw_data needs to be placed in a folder called 'raw_data', placed in the same directory as picking_isochrones.
Here, a folder 'pick_data' will also be created by the programm, where the radar_data in connection with the picked layers is saved.

Options:

create_new_geoinfo: If a file with the stated output-name (filename_geoinfo) already exists, this option can be activated to force the creation of a new output-file.

keep_old_picks: If a new output-file is created, while a old file exists, picks of the old file can be transferred with this option. Note: Until now, this does not correct the position of the picks, if the limits of the radargram are changed.

load_crossover: If another outputfile with picked layers already exists, you can activate this option to find cross-points.

Figure 2:

You can pick in figure 2. Therefore, 3 input-types are used: left-click, right-click and enter. With clicking, the layers can be changed. Each click needs to be confirmed by pressing enter. Additionally, you can switch between picking mode and move-/zoom-mode, by pushing enter (If no click was made). 

With the first left-click, a layer is traced to both directions starting from the click-position.

Afterwards you can left-click to force the layer to a specific point and trace it from there onwards.

With a right-click you can delete all points in the layer on the right side of the click position. To creat a gap in the layer, you can use this to cut it off and start it over again with another left-click.

If the option 'Go left' is activated, you can do the same as above, just in the other direction.

If you misclick and overwrite or delete you previously picked layer. Don't panick (if you have saved it)! You can break the programm (STRG+C) and run it again (with create_new_geoinfo = 0) and your previous picks will be loaded. Don't press 'Save picks' or 'End picking' and everything is fine. 

The picker can save up to 8 different layers, between which you can switch by selecting {Layer1,...,Layer8}. Picks of the active layer are shown in blue, picks of other layers in black.
You can save the current picks by pressing 'Save picks'.
You can finish picking by pressing 'End picking' (This does not work smooth. To finally leave the picking-loop, you need to click on the radargram an press enter).
