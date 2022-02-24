# picking_isochrones

#needs MATLABS signal processing toolbox

To pick layers in airborne radar data you need to run 'picker_mcords.m' or 'picker_gpr', in which you can also set the options for the picking.
'picker_mcords2.m' is set up to run one specific example.

%%% Input
Data:
First, you can specify the folder directories and prefixes for the names of the raw data and the output data files.
Subsecuently, you can set by 'input_section' the number of the radargram that you want to work on.
With 'cross_section' you can select radargrams from which you want to find the cross-over points (if activated, see below). Specify them either as a list, e.g. {'006'; '009'} (note the curly brackets), or by selecting 'all' radargrams in the 'output_folder' (without brackets).

Options:
The following options can be activated by setting their value to 1 and deacitvate by setting it to 0.

'create_new_geoinfo': If a file with the stated output-name ('output_prefix' + 'input_section') already exists, this option can be activated to force the creation of a new output-file. Otherwise work will be continued on the existing file.

'update_bottom': With this option the update of the bottom pick can be forced in an existing file. If a new file is created, a new bottom will be created in any case and this option is obsolete.

'update_seeds': This option can be used to force the computation of new seeds. Needed, if you want to change some of the corresponding tuning parameter (see below) afterwards. If a new geoinfo is created or the bottom is updated, new seeds will be computed anyway.

keep_old_picks: If a new output-file is created with 'create_new_geoinfo', while a old file exists, picks of the old file can be transferred with this option.

load_crossover: If this option is activated, cross-over points will be determined, as selected in 'cross_section'.

With 'len_color_range' and 'cmp' you can set the color range and the colormap of the picker.

Tuning parameters:
This section contains options that affect the appearance of the processed radargram (e.g. how the seeds are computed). They are stored in the geoinfo under geoinfo.tp. If you load a previously created geoinfo, all tuning parameters, but 'clms', 'rows' and 'num_bottom_peaks' are overwritten, with your current selected settings.
Note: 'clms' can either be a range (e.g.: 1:500) or it can be set to 'full' so that the full range of the loaded radargram is selected.

%%% Processing-figures
Figure 1: Surface and bottom pick
This figure shows the surface and bottom pick. If 'create_new_geoinfo'=1 or 'update_bottom'=1, a pop-up window appears, which allows, to update the bottom-pick, which crucially affects the computation of seeds. The bottom pick is processed iteratively. Starting from the strongest return signal on the left side, the bottom pick of the next row is selected as the signal peak, which is closest to the row of the previous bottom pick, whereat always the 'num_bottom_peaks' strongest peaks in each row are considered. Depending on the dominance of the bottom pick the parameter 'num_bottom_peaks' can hence be used to tune the picker, such that it not looses the bottom signal.

In case that no strong bottom signal exists in certain lines, the bottom-picker will loose track and produce strong outliers. With activating the second option of the pop-up window ('pick MinBinForBottomPick manually'), a manual picker is started after pressing ok. This manual picker tracks all clicks and converges them into a variable 'MinBinForBottomPick', which can be used to cut off outliers.

When you are happy with your bottom-pick you can press 'Cancel' to continue.


Figure 2: Layer picker
This figure initially shows the radargram in the background and the seeds. Here, you can pick your layers. Therefore, 3 input-types are used: left-click, right-click and enter. With clicking, the layers can be changed. Each click needs to be confirmed by pressing enter. Additionally, you can switch between picking mode and move-/zoom-mode, by pushing enter (If no click was made). 

With the first left-click, a layer is traced to both directions starting from the click-position. Afterwards you can left-click to force the layer to a specific point and trace it from there onwards.

With a right-click you can delete all points in the layer on the right side of the click position. To creat a gap in the layer, you can use this to cut it off and start it over again with another left-click.

If the option 'Go left' is active, you can do the same as above, just in the other direction.
If the option 'Edit mode' is active, not all, but only the next 'tp.editing_window' points are traced or deleted.

If you misclick and overwrite or delete you previously picked layer, you can undo your last pick by pressing 'Undo pick'. Caution: this option has no long-term memory and can only undo the very last action. However, if you realize your mistake too late, you can still restore any saved changes by breaking the programm (STRG+C) and running it again (with create_new_geoinfo = 0).

The picker can save up to 10 different layers, between which you can switch by selecting {Layer1,...,Layer10}. Picks of the active layer are shown in blue, picks of other layers in black.

You can save the current picks by pressing 'Save picks'.
You can finish picking by pressing 'End picking', this will also save you current picks. (This does not work smooth. To finally leave the picking-loop, you need to click on the radargram an press enter).


# Editing data files from pick

To conduct some simple corrections of your data files, you can run 'edit_datafiles.m'.

This script can be used to 'swap' two layers, to 'overwrite' one layer with another (from the same or from a different file) or to simply 'view' a pick file.

# Trouble Shooting, common errors

'Reference to non-existent field 'peakim'.' this is often related to tp.bgSkip = 50. This means that the picker needs to have at least 50 bins below the picked bottom layer. It uses this as 'background noise' to calculate the seed points. Solution: adjust tp.rows to shore more or adjust BinForBottomPick 
