# Quick start guide to the picker

**Requirements:** Installation of Matlab's signal processing toolbox

## Specify input data, options and tuning parameters 

**Data:**

* *Input type*: The picker can process different types of input files. Specify the input type here.
* *Input folder*: Specify the location of your raw data here.  
* *Input file*: Specify the filename of the raw data. 
* *Output folder*: Specify the location where your picks should be stored. 
* *Output prefix*: Specify the prefix of your output filename. 
* *Output suffix*: Specify the suffix of your output filename.
* *File metadata:*: Specify the location where your metadata should be stored. 
* *Cross-section*: With this you can select radargrams from which you want to find the cross-over points (if activated, see below). Specify them either as a list, e.g. {'006'; '009'} (note the curly brackets), or by selecting 'all' radargrams in the output folder (without brackets).
* Specify information about operator, GPR device and acquisition time etc. in the next lines. 

**Options:**

The following options can be activated by setting them to 1 and deactivated by setting them to 0. 

* *create_new_geoinfo*: If a file with the stated output name ('output_prefix' + 'input_section') already exists, this option can be activated to force the creation of a new output file. Otherwise, the picker will continue with the already existing output file.
* *update_bottom*: With this option the update of the bottom pick can be forced in an existing file. If a new output file is created, a new bottom will be picked in any case and this option is obsolete.
* *update_seeds*: This option can be used to force the computation of new seeds. Needed, if you want to change some of the corresponding tuning parameter (see below) afterwards. If a new output file is created or the bottom is updated, new seeds will be computed anyway.
* *keep_old_picks*: If a new output file is created with 'create_new_geoinfo' while an old output file exists, picks of the old file can be transfered to the new file with this option.
* *load_crossover*: If this option is activated, cross-over points will be determined and plotted in the picking figure as selected in 'cross_section'.
* *delete_stripes*: If this option is activated, the horizontal mean will be subtracted from the radar data. This option was introduced as some GPR radargrams showed horizontal noise. 
* *filter_frequencies*: If this option is activated, frequencies higher than 10 MHz will be filtered from signal. This option only applies to GPR_LF data and can be used as an alternative to delete_stripes.
* *median_peaks*: If this option is activated, median intensities from a tp.window x tp.window (see below) environment are used instead of the normal intensites to determine intensity maxima or minima, respectively.
* *nopeak_step*: If this option is activated, the direction of the previous step is used to propagate the layer in case no intensity extremum can be found instead of propagating the layer horizontally.  
* *find_maxima*: If this option is activated, intensity maxima are picked. Otherwise, intensity minima are picked. 

**Appearance:**

With 'len_color_range' and 'cmp' you can set the color range and the colormap of the picker. 
The editing_window determines the number of traces that are updated in edit mode. 

**Tuning parameters:**

This section contains options that affect the appearance of the processed radargram (e.g. how the seeds are computed). They are stored in the output file under geoinfo.tp. If you load  previously created geoinfo file, all tuning parameters except for 'clms', 'rows' and 'num_bottom_peaks' will be overwritten with your current selected settings.

* *clms*: Select the traces of the radargram. Note that clms can either be a range (e.g. 1:500) or it can be set to 'all_clms' so that all traces of the radargram are selected. If an existing file is loaded, this option will be overwritten. 
* *rows*: Select the rows of the radargram (corresponding with depth) that will be shown. Should be specified as a range, e.g. 1:5000. You can cut the radargram to limit processing time. 
* *MinBinForSurfacePick*: Specify the upper boundary bin below which the surface is picked. 
* *MinBinForBottomPick*: Specify the upper boundary bin below which the bottom will be picked. 
* *MaxBinForBottomPick*: Specify the lower boundary bin above which the bottom will be picked. 
* *num_bottom_peaks*: This states the number of strongest peaks considered as bottom pick.
* *window*: This defines the size of the vertical window in which intensity maxima/minima are determined for layer propagation. 
* *nopeaks_window*: This defines the number of traces over which the direction of layer propagation will be averaged to propagate the layer in case no intensity peaks can be found.
* *weight_factor*: This states how much the previous direction of layer propagation is weighted in comparison to peak prominence of the intensity maxima/minima in case several extrema are found in the vertical window. 

## How to pick bottom, surface and layers

You can start the picker by either opening the picker_gpr.m or the picker_mcords_adapted.m file and pressing the 'run' button afterwards. After starting the picker, two figures will appear. The first figure allows to pick bottom and surface while the second figure allows picking of the internal layers. 

**Figure 1:**

This figure shows the surface and bottom pick. If 'create_new_geoinfo'=1 or 'update_bottom'=1 is chosen, a pop-up window appears, which allows to update the bottom pick, which crucially affects the computation of seeds. The bottom pick is processed iteratively. Starting from the strongest return signal on the left side, the bottom pick of the next row is selected as the signal peak, which is closest to the row of the previous bottom pick, whereat always the 'num_bottom_peaks' strongest peaks in each row are considered. Depending on the dominance of the bottom pick the parameter 'num_bottom_peaks' can hence be used to tune the picker, such that it not looses the bottom signal.

In case that no strong bottom signal exists in certain lines, the bottom-picker will loose track and produce strong outliers. To cut off outliers the options 'MinBinForBottomPick' or 'MaxBinForBottomPick' in the pop-up window can be activated (only one at a time). With activating the respective option, a manual picker is started after pressing ok. With clicking you can manually define the variable 'MinBinForBottomPick' (or 'MaxBinForBottomPick', respectively) as this manual picker tracks all clicks and converges them into the corresponding variable. After setting the upper (or lower boundary) by clicking, you should press the Enter key to confirm your choice. 

When you are happy with your bottom pick you can press 'Cancel' to continue.

**Figure 2:**

This figure initially shows the radargram (and the seeds in case of MCoRDS data) and here you can start picking the internal layers. To pick the layers, three input types are used:

* left-click
* right-click
* pressing the Enter key

With clicking, you can determine where your layer should propagate. After each click you need to confirm your choice by pressing the Enter key. If no click was made, you can press the Enter key to switch between picking mode and move-/zoom-mode. 

If you want to start picking a layer, you should first determine the number of this layer by selecting it from the menu below containing 'Layer1', 'Layer2', ... . Currently, up to 18 layers can be picked. Picks of the active layer are shown in purple, picks of other layers in black.

With the first left-click (followed by pressing the Enter key), a layer is traced to both directions starting from the position of the click. Afterwards you can left-click to correct an incorrectly propagated layer and force it to a specific point and trace it from there onwards.

With a right-click you can delete all points of the layer on the right side of the click position. To create a gap in the layer, you can use this to cut it off and start it over again some place to the right with another left-click.

If the option 'Go left' is active, you can do the same as above, just in the other direction.
If the option 'Edit mode' is active, not all, but only the next 'tp.editing_window' points are corrected or deleted.

If you misclick and overwrite or delete you previously picked layer, you can undo your last pick by pressing 'Undo pick'. Caution: this option has no long-term memory and can only undo the very last action. However, if you realize your mistake too late, you can still restore any saved changes by breaking the programm (STRG+C) and running it again (with create_new_geoinfo = 0).

You can save the current picks by pressing 'Save picks'.
You can finish picking by pressing 'End picking', this will also save you current picks. (This does not work smoothly. To finally leave the picking-loop, you need to click on the radargram and press enter. If problems still occur here, you can force the picker to terminate with pressing STRG+C after saving the picks.).







