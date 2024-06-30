// @author: Jiageng Liu

run("Close All");
logOutput=1;

wellAnalysis = getDirectory("Open well folder");
listAnalysis = getFileList(wellAnalysis);

PIV_Force = wellAnalysis + "PIV_Force/";
PIV_Force_series = getFileList(PIV_Force); 
num_of_series = PIV_Force_series.length;
suffix = substring(wellAnalysis, wellAnalysis.length - 3, wellAnalysis.length-1);
run("ROI Manager...");
roiManager("reset");

function cal_percentile(percentile){ // this function calculates percentile; 
	nBins = 300000; 
	getHistogram(values, counts, nBins);
	
	histo_sum = newArray(nBins);
	histo_sum[0] = counts[0];
	for (i = 1; i < nBins; i++){ 
		histo_sum[i] = counts[i] + histo_sum[i-1]; 
	}
	
	//normalize the cumulative histogram
	denom_histo = newArray(nBins);
	for (i = 0; i < nBins; i++){  
		denom_histo[i] = histo_sum[i]/histo_sum[nBins-1]; }


	i = 0;
	do {
	    i = i + 1;

	} while (denom_histo[i] < percentile)
	return values[i];
}

Dialog.create("Please indicate whether fluorescence signals are nuclear");
signal_choice=newArray();
signal_choice=Array.concat(signal_choice,"nuclear");
signal_choice=Array.concat(signal_choice,"non-nuclear");
Dialog.addChoice("DAPI:",signal_choice);
Dialog.addChoice("CY5:",signal_choice);
Dialog.addChoice("FarRed:",signal_choice);
Dialog.addChoice("GFP:",signal_choice);
Dialog.show();
DAPI_nuclear= Dialog.getChoice();
CY5_nuclear= Dialog.getChoice();
FarRed_nuclear= Dialog.getChoice();
GFP_nuclear= Dialog.getChoice();

GFP_test = wellAnalysis + "series_01/" + "GREEN01.tif";
FarRed_test = wellAnalysis + "series_01/" + "FarRed01.tif";
DAPI_test = wellAnalysis + "series_01/" + "DAPI01.tif";
CY5_test = wellAnalysis + "series_01/" + "CY501.tif";

showMessage("<html>"+"<big>"+"<font color=red>Please determine thresholds for fluorescence channels.");

open(GFP_test);
GFP_test_window = getTitle();
run("Histogram");
Dialog.create("Percentile threshold for GFP positive");
Dialog.addNumber("percentile threshold:",0.99); // adjust the thresholds based on imaging 
Dialog.show();
GFP_threshold = Dialog.getNumber();
selectWindow(GFP_test_window); // please do not select other images when running the program


okThreshold = false;
num_attampt = 1;
while (okThreshold == false){
	waitForUser("please check threshold");
	okThreshold2=getBoolean("Is the threshold appropriate?");
 	if (okThreshold2==true){
		okThreshold=true;
	}
			
	if (okThreshold2==false){
		//waitForUser("Please test a new threshold");
		Dialog.create("New percentile threshold for GFP positive");
		Dialog.addNumber("percentile threshold:",0.99);
		Dialog.show();
		GFP_threshold = Dialog.getNumber();
		selectWindow(GFP_test_window);
		print(cal_percentile(GFP_threshold));
	}	
}

open(FarRed_test);
FarRed_test_window = getTitle();
run("Histogram");
Dialog.create("Percentile threshold for FarRed positive");
Dialog.addNumber("percentile threshold:",0.99);
Dialog.show();
FarRed_threshold = Dialog.getNumber();
selectWindow(FarRed_test_window); // please do not select other images when running the program
print(cal_percentile(FarRed_threshold));


okThreshold = false;
num_attampt = 1;
while (okThreshold == false){
	waitForUser("please check threshold");
	okThreshold2=getBoolean("Is the threshold appropriate?");
 	if (okThreshold2==true){
		okThreshold=true;
	}
			
	if (okThreshold2==false){
		//waitForUser("Please test a new threshold");
		Dialog.create("New percentile threshold for FarRed positive");
		Dialog.addNumber("percentile threshold:",0.99);
		Dialog.show();
		FarRed_threshold = Dialog.getNumber();
		selectWindow(FarRed_test_window);
		print(cal_percentile(FarRed_threshold));
	}	
}

open(DAPI_test);
DAPI_test_window = getTitle();
run("Histogram");
Dialog.create("Percentile threshold for DAPI positive");
Dialog.addNumber("percentile threshold:",0.99);
Dialog.show();
DAPI_threshold = Dialog.getNumber();
selectWindow(DAPI_test_window); // please do not select other images when running the program
print(cal_percentile(DAPI_threshold));


okThreshold = false;
num_attampt = 1;
while (okThreshold == false){
	waitForUser("please check threshold");
	okThreshold2=getBoolean("Is the threshold appropriate?");
 	if (okThreshold2==true){
		okThreshold=true;
	}
			
	if (okThreshold2==false){
		//waitForUser("Please test a new threshold");
		Dialog.create("New percentile threshold for DAPI positive");
		Dialog.addNumber("percentile threshold:",0.99);
		Dialog.show();
		DAPI_threshold = Dialog.getNumber();
		selectWindow(DAPI_test_window);
		print(cal_percentile(DAPI_threshold));
	}	
}

open(CY5_test);
run("Median...", "radius=10");
CY5_test_window = getTitle();
run("Histogram");
Dialog.create("Percentile threshold for CY5 positive");
Dialog.addNumber("percentile threshold:",0.99);
Dialog.show();
CY5_threshold = Dialog.getNumber();
selectWindow(CY5_test_window); // please do not select other images when running the program
print(cal_percentile(CY5_threshold));


okThreshold = false;
num_attampt = 1;
while (okThreshold == false){
	waitForUser("please check threshold");
	okThreshold2=getBoolean("Is the threshold appropriate?");
 	if (okThreshold2==true){
		okThreshold=true;
	}
			
	if (okThreshold2==false){
		//waitForUser("Please test a new threshold");
		Dialog.create("New percentile threshold for CY5 positive");
		Dialog.addNumber("percentile threshold:",0.99);
		Dialog.show();
		CY5_threshold = Dialog.getNumber();
		selectWindow(CY5_test_window);
		print(cal_percentile(CY5_threshold));
	}	
}
run("Close All");


for (ii=0; ii<num_of_series;ii++){
	suffix_sub = substring(PIV_Force_series[ii], PIV_Force_series[ii].length-3, PIV_Force_series[ii].length-1);
	the_serie_path = wellAnalysis + "series_"+suffix_sub+"/"; 
	the_serie_PIV_path = wellAnalysis + "PIV_Force/" + "series_"+suffix_sub+"/"; 
	the_serie_PIV_montage = the_serie_PIV_path + "montage/";
	
	the_serie_disp_map = wellAnalysis + "PIV_Force/" + "series_"+suffix_sub+"/"+"aligned_well_"+suffix+"_series_"+suffix_sub+".tif_PIV3_vPlot.tif";
	the_serie_force_map = wellAnalysis + "PIV_Force/" + "series_"+suffix_sub+"/"+"MagnitudeMap_aligned_well_"+suffix+"_series_"+suffix_sub+".tif";
	the_serie_force_map_filtered = wellAnalysis + "PIV_Force/" + "series_"+suffix_sub+"/"+"background_subtracted_force_map.tif";
	
	the_serie_cell_bef_fix = the_serie_path+"cell_before_treatment"+suffix_sub+".tif";
	the_serie_cell_aft_fix = the_serie_path+"cell_after_treatment"+suffix_sub+".tif";
	the_serie_cell_aft_stain = the_serie_path+"cell_after_staining"+suffix_sub+".tif";
	the_serie_cell_CY5 = the_serie_path+"CY5"+suffix_sub+".tif";
	the_serie_cell_DAPI = the_serie_path+"DAPI"+suffix_sub+".tif";
	the_serie_cell_FarRed = the_serie_path+"FarRed"+suffix_sub+".tif";
	the_serie_cell_GFP = the_serie_path+"GREEN"+suffix_sub+".tif";

	// Let's first adjust the global drift 
	open(the_serie_force_map_filtered);
	force_map_filtered = getTitle();
	open(the_serie_cell_CY5);
	CY5 = getTitle();
	open(the_serie_cell_FarRed);
	FarRED = getTitle();
	open(the_serie_cell_GFP);
	GFP = getTitle();
	open(the_serie_cell_aft_fix);
	cell_aft_fix = getTitle();
	open(the_serie_cell_DAPI);
	DAPI = getTitle();
	setTool("rectangle");
	waitForUser("Please mark points"); // you will need to mark the same number of points between two figures; I usually do "cell after fix" and "DAPI"; if you want to label multiple images you'll need to adjust the codes below
	// you can press shift-a to delete points 
	n = roiManager("count"); // this is the total number of points between two images; you would need to divide by 2 to get the points for each image

	X_original = newArray(); // this refers to the images correctly corresponding to the force map (e.g. cell after fix, which is the reference image for force calculation)
	Y_original = newArray();
	
	X_afterIF = newArray();  // this refers to the IF images which may experience global drift
	Y_afterIF = newArray();

	for (i = 0; i < n; i++) {
		if (i < n/2) {
			roiManager("select", i);
			name =split(Roi.getName,"-");
			cur_x = parseFloat(name[1]); cur_y = parseFloat(name[0]); 
			X_original = Array.concat(X_original,cur_x);
			Y_original = Array.concat(Y_original,cur_y);
		}
		if (i >= n/2 && i < n) {
			roiManager("select", i);
			name =split(Roi.getName,"-");
			cur_x = parseFloat(name[1]); cur_y = parseFloat(name[0]); 
			X_afterIF = Array.concat(X_afterIF,cur_x);
			Y_afterIF = Array.concat(Y_afterIF,cur_y);
		}
	}

	selectWindow(cell_aft_fix);
	makeSelection("point", X_original, Y_original);
	selectWindow(DAPI);
	makeSelection("point", X_afterIF, Y_afterIF);
	run("Landmark Correspondences", "source_image="+DAPI+" template_image="+cell_aft_fix+" transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate");
	selectWindow(DAPI);
	run("Close");
	Trans_DAPI = "Transformed"+DAPI;

	selectWindow(CY5);
	makeSelection("point", X_afterIF, Y_afterIF);
	run("Landmark Correspondences", "source_image="+CY5+" template_image="+cell_aft_fix+" transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate");
	selectWindow(CY5);
	run("Close");
	Trans_CY5 = "Transformed"+CY5;
	

	selectWindow(FarRED);
	makeSelection("point", X_afterIF, Y_afterIF);
	run("Landmark Correspondences", "source_image="+FarRED+" template_image="+cell_aft_fix+" transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate");
	selectWindow(FarRED);
	run("Close");
	Trans_FarRed = "Transformed"+FarRED;

	selectWindow(GFP);
	makeSelection("point", X_afterIF, Y_afterIF);
	run("Landmark Correspondences", "source_image="+GFP+" template_image="+cell_aft_fix+" transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate");
	selectWindow(GFP);
	run("Close");
	Trans_GFP = "Transformed"+GFP;
	roiManager("reset");

	// cell detection using mechaine learning
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+Trans_DAPI+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	//waitForUser("Please check cell detection");

	
	while (true) {
		n = roiManager("count");
		x_cord = newArray(); 
		y_cord = newArray();
		widths = newArray();
		heights = newArray();
		del_flags = newArray(n);
		del_cells = newArray();
		// loop through the ROI Manager
		
		for (i = 0; i < n; i++) {
			flag = false;
		    roiManager("select", i);
		    // process roi here
			name =split(Roi.getName,"-");
			cur_x = parseFloat(name[1]); cur_y = parseFloat(name[0]); 
				
			//Roi.getCoordinates(xpoints, ypoints); 	
		    Roi.getBounds(x, y, width, height); 
		    x_cord = Array.concat(x_cord, cur_x); 
			y_cord = Array.concat(y_cord, cur_y); 
			widths = Array.concat(widths, width); //this is the pixel distance from the very left to right side of the ROI object
		    heights = Array.concat(heights, height); //this is the pixel distance from the very top to bottom of the ROI object
		    // everthing is in pixel

		    size_of_cell = (parseFloat(width) + parseFloat(height))/2;
		    
		    // get rid of cell debris; we assume debris has a size smaller than 5 um which is about 25 pixel
		    if ((size_of_cell < parseFloat(25)) || (size_of_cell > parseFloat(80))){
		    	//roi2delete = Array.concat(roi2delete, i)
		    	flag = true;
		    }
		
			// get rid of cell on the edge
			if ((cur_x < parseFloat(50)) || (cur_x > parseFloat(1998))) {
		    	flag = true;
			}
			
			if ((cur_y < parseFloat(50)) || (cur_y > parseFloat(1998))) {
		    	flag = true;
			}
		
			if (flag == true){
				del_flags[i] = true;
		    	del_cells = Array.concat(del_cells, i);
			}
		}
		
		for (i = 0; i < n; i++) {
		 	for (j = 0; j < n; j++) {
		  		d = Math.sqrt((x_cord[i] - x_cord[j]) * (x_cord[i] - x_cord[j]) + (y_cord[i] - y_cord[j]) * (y_cord[i] - y_cord[j]));
		  		
			  	if (i != j && d < maxOf(heights[i] + widths[i], heights[j]+ widths[j])) {
			   		if (!del_flags[i]) {
			    		del_flags[i] = true;
			    		del_cells = Array.concat(del_cells, i);
			   		}
			
			   		if (!del_flags[j]) {
			    		del_flags[j] = true;
			    		del_cells = Array.concat(del_cells, j);
			   		}
			  	}
		 	}
		}
		
		detected_cell_index = newArray();
		for (m=0; m<n; m++){
			if (del_flags[m] == false){
				detected_cell_index = Array.concat(detected_cell_index, m);
			}
		}
	
		selectWindow(Trans_DAPI);
		roiManager("select", detected_cell_index);
		roiManager("combine");
		waitForUser("Please check cell detection after filtering");
		cell_filter_ok = getBoolean("Are you satisfied with the previous cell selection?"); 
		if (cell_filter_ok) {
			break;
		}
	}
	Array.print(detected_cell_index);
	roiManager("Save", the_serie_PIV_path+"RoiSet.zip");

	// Now we are extracting force from each cell
	energy_withinCells = newArray(detected_cell_index.length);
	force_withinCells = newArray(detected_cell_index.length);
	displacement_withinCells = newArray(detected_cell_index.length);
	pascal_withinCells = newArray(detected_cell_index.length); 
	count = newArray(detected_cell_index.length); 
	
	each_series_energy = File.openAsString(the_serie_PIV_path+"Energy_forces_new.txt"); 
	rows = split(each_series_energy, "\n");
	for (i=0; i<rows.length; i++){
		
		cur_row = split(rows[i], "\t ");
		point_x = cur_row[1]; point_y = cur_row[2];
		for (j=0; j<detected_cell_index.length; j++){
			roiManager("select", detected_cell_index[j]);

			Roi.getBounds(x, y, width, height);
			x_center = x + width/2;
			y_center = y + height/2;
			makeRectangle(x_center-width, y_center-height, width*2, height*2);				
			cur_pascal = parseFloat(cur_row[6]);
			if (Roi.contains(point_x, point_y) && cur_pascal>5){
				count[j] ++;
				energy_withinCells[j] += parseFloat(cur_row[3]);
				force_withinCells[j] += parseFloat(cur_row[4]);
				displacement_withinCells[j] += parseFloat(cur_row[5]);
				pascal_withinCells[j] += parseFloat(cur_row[6]); 
			}
		}	
	}

	Array.print(energy_withinCells);
	Array.print(force_withinCells);
	Array.print(count);
	for (i=0; i<detected_cell_index.length; i++){
		if (count[i] > 0){
			energy_withinCells[i] /= parseFloat(count[i]);
			force_withinCells[i] /= parseFloat(count[i]);
			displacement_withinCells[i] /= parseFloat(count[i]);
			pascal_withinCells[i] /= parseFloat(count[i]); //add this to new codes		
		}		
	}
	
	cell_force_measurment=File.open(the_serie_PIV_path+"force_within_cells.txt");
	for (i=0;i<detected_cell_index.length;i++){
		if (count[i] > 0){
			print(cell_force_measurment,suffix_sub + "\t "+detected_cell_index[i]+"\t "+energy_withinCells[i]+"\t "+ force_withinCells[i]+ "\t "+ displacement_withinCells[i] +"\t "+ pascal_withinCells[i]);
		}	
	}
	File.close(cell_force_measurment);

	// Now we see whether cells are positive for different staining

	selectWindow(cell_aft_fix);
	x = getWidth();
	y = getHeight();

	detected_DAPI = newArray(detected_cell_index.length);
	detected_CY5 = newArray(detected_cell_index.length);
	detected_FarRed = newArray(detected_cell_index.length);
	detected_GFP = newArray(detected_cell_index.length);

	selectWindow(Trans_DAPI);
	if (DAPI_nuclear == "nuclear") {
		for (k=0; k<detected_cell_index.length; k++){	
			roiManager("select", detected_cell_index[k]);
			Roi.getContainedPoints(xpoints, ypoints);
			for (m=0; m<xpoints.length; m++){
				detected_DAPI[k] += getPixel(xpoints[m],ypoints[m]);		
			}	
			if (xpoints.length > 0) {
				detected_DAPI[k] /= xpoints.length;	
			}
		}
	}
	
	else{
		for (k=0; k<detected_cell_index.length; k++){
			roiManager("select", detected_cell_index[k]);
			Roi.getBounds(x, y, width, height);
			x_center = x + width/2;
			y_center = y + height/2;
			makeRectangle(x_center-width, y_center-height, width*2, height*2);	
			Roi.getContainedPoints(xpoints, ypoints);
			cur_count = 0;
			for (m=0; m<xpoints.length; m++){
				pixel = getPixel(xpoints[m],ypoints[m]);
				if (pixel > 130) {
					detected_DAPI[k] += getPixel(xpoints[m],ypoints[m]);
					cur_count++;
				}
					
			}	
			if (cur_count > 0) {
				detected_DAPI[k] /= cur_count;
			}
		}
	}

	selectWindow(Trans_CY5);
	if (CY5_nuclear == "nuclear") {
		for (k=0; k<detected_cell_index.length; k++){	
			roiManager("select", detected_cell_index[k]);
			Roi.getContainedPoints(xpoints, ypoints);
			for (m=0; m<xpoints.length; m++){
				detected_CY5[k] += getPixel(xpoints[m],ypoints[m]);		
			}	
			if (xpoints.length > 0) {
				detected_CY5[k] /= xpoints.length;	
			}
		}
	}
	
	else{
		for (k=0; k<detected_cell_index.length; k++){
			roiManager("select", detected_cell_index[k]);
			Roi.getBounds(x, y, width, height);
			x_center = x + width/2;
			y_center = y + height/2;
			makeRectangle(x_center-width, y_center-height, width*2, height*2);	
			Roi.getContainedPoints(xpoints, ypoints);
			cur_count = 0;
			for (m=0; m<xpoints.length; m++){
				pixel = getPixel(xpoints[m],ypoints[m]);
				if (pixel > 130) {
					detected_CY5[k] += getPixel(xpoints[m],ypoints[m]);
					cur_count++;
				}
					
			}	
			if (cur_count > 0) {
				detected_CY5[k] /= cur_count;
			}
		}
	}

	selectWindow(Trans_FarRed);
	if (FarRed_nuclear == "nuclear") {
		for (k=0; k<detected_cell_index.length; k++){	
			roiManager("select", detected_cell_index[k]);
			Roi.getContainedPoints(xpoints, ypoints);
			for (m=0; m<xpoints.length; m++){
				detected_FarRed[k] += getPixel(xpoints[m],ypoints[m]);		
			}	
			if (xpoints.length > 0) {
				detected_FarRed[k] /= xpoints.length;	
			}
		}
	}
	
	else{
		for (k=0; k<detected_cell_index.length; k++){
			roiManager("select", detected_cell_index[k]);
			Roi.getBounds(x, y, width, height);
			x_center = x + width/2;
			y_center = y + height/2;
			makeRectangle(x_center-width, y_center-height, width*2, height*2);	
			Roi.getContainedPoints(xpoints, ypoints);
			cur_count = 0;
			for (m=0; m<xpoints.length; m++){
				pixel = getPixel(xpoints[m],ypoints[m]);
				if (pixel > 130) {
					detected_FarRed[k] += getPixel(xpoints[m],ypoints[m]);
					cur_count++;
				}
					
			}	
			if (cur_count > 0) {
				detected_FarRed[k] /= cur_count;
			}
		}
	}

	selectWindow(Trans_GFP);
	if (GFP_nuclear == "nuclear") {
		for (k=0; k<detected_cell_index.length; k++){	
			roiManager("select", detected_cell_index[k]);
			Roi.getContainedPoints(xpoints, ypoints);
			for (m=0; m<xpoints.length; m++){
				detected_GFP[k] += getPixel(xpoints[m],ypoints[m]);		
			}	
			if (xpoints.length > 0) {
				detected_GFP[k] /= xpoints.length;	
			}
		}
	}
	
	else{
		for (k=0; k<detected_cell_index.length; k++){
			roiManager("select", detected_cell_index[k]);
			Roi.getBounds(x, y, width, height);
			x_center = x + width/2;
			y_center = y + height/2;
			makeRectangle(x_center-width, y_center-height, width*2, height*2);	
			Roi.getContainedPoints(xpoints, ypoints);
			cur_count = 0;
			for (m=0; m<xpoints.length; m++){
				pixel = getPixel(xpoints[m],ypoints[m]);
				if (pixel > 130) {
					detected_GFP[k] += getPixel(xpoints[m],ypoints[m]);
					cur_count++;
				}
					
			}	
			if (cur_count > 0) {
				detected_GFP[k] /= cur_count;
			}
		}
	}

	the_serie_data = File.open(the_serie_PIV_path+"the_serie_data.txt");
	for (k=0; k<detected_cell_index.length; k++){ // here we calculate the average pixel value within Rois 		
		print(the_serie_data, suffix_sub + "\t "+detected_cell_index[k]+"\t "+detected_DAPI[k]+"\t "+ detected_CY5[k]+ "\t "+ detected_FarRed[k] +"\t "+ detected_GFP[k]+"\t "+energy_withinCells[k]+"\t "+ force_withinCells[k]+ "\t "+ displacement_withinCells[k] +"\t "+ pascal_withinCells[k]);

	}
	File.close(the_serie_data);
	roiManager("reset");


	selectWindow(cell_aft_fix);
	cell_title = "cells_after_fix"+suffix_sub+".tif";
	run("Duplicate...", "title="+cell_title);
	run("RGB Color");
	for (i=0;i<detected_cell_index.length;i++){
		x_position = x_cord[detected_cell_index[i]];
		y_position = y_cord[detected_cell_index[i]];
		energy_of_cell = "energy (J): "+energy_withinCells[i];
		force_of_cell = "force (N): "+force_withinCells[i];
		displacement_of_cell = "displacement (um): "+displacement_withinCells[i];
		pascal_of_cell = "pascal (PA): "+pascal_withinCells[i]; //ADD THIS TO NEW CODE
		selectWindow(cell_title);
		setColor(255,0,0);
		setFont("Serid", 33, "Italic");
		drawString(energy_of_cell, x_position+75, y_position-113);
		drawString(force_of_cell, x_position+75, y_position-80);
		drawString(displacement_of_cell, x_position+75, y_position-44);
		drawString(pascal_of_cell, x_position+75, y_position-11);
	}
	roiManager("show all with labels");
	cell_labeled_title = "cells_labeled_with_measurments"+suffix_sub+".tif";
	//saveAs("Tiff", the_serie_path+cell_labeled_title);
	saveAs("Tiff", the_serie_PIV_path+cell_labeled_title);
	selectWindow(cell_labeled_title);
	run("Close");

	

	open(the_serie_force_map);
	force_map = getTitle();
	open(the_serie_disp_map);
	disp_map = getTitle();
	open(the_serie_cell_aft_stain);
	cell_aft_stain = getTitle();
	for (i=1;i<detected_cell_index.length+1;i++){
		if (i < 10) {
			cell_sub = "0" + i; 
		}
		else {
			cell_sub = "" + i;
		}

		if (!File.exists(the_serie_PIV_montage)) {
			File.makeDirectory(the_serie_PIV_montage);
		}
		
		j = detected_cell_index[i-1]; 
		cell_x = parseInt(x_cord[j]); cell_y = parseInt(y_cord[j]); 
		cell_wid = widths[j]; cell_hei = heights[j];
		size = maxOf(parseInt(cell_wid), parseInt(cell_hei));

		selectWindow(cell_aft_fix);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		cell_aft_fix_title = "cell_after_fix"+cell_sub+".tif";
		run("Duplicate...", "title="+cell_aft_fix_title);
		
		selectWindow(force_map);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		force_title = "force_"+cell_sub+".tif";
		run("Duplicate...", "title="+force_title);

		selectWindow(force_map_filtered);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		force_filtered_title = "force_filtered_"+cell_sub+".tif";
		run("Duplicate...", "title="+force_filtered_title);
		
		selectWindow(disp_map);
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		disp_title = "disp_"+cell_sub+".tif";
		run("Duplicate...", "title="+disp_title);

		selectWindow(cell_aft_stain);
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		cell_aft_stain_title = "cell_after_stain"+cell_sub+".tif";
		run("Duplicate...", "title="+cell_aft_stain_title);

		selectWindow(Trans_DAPI);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		cell_Trans_DAPI_title = "cell_Trans_DAPI"+cell_sub+".tif";
		run("Duplicate...", "title="+cell_Trans_DAPI_title);

		selectWindow(Trans_CY5);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		cell_Trans_CY5_title = "cell_Trans_CY5"+cell_sub+".tif";
		run("Duplicate...", "title="+cell_Trans_CY5_title);
		
		selectWindow(Trans_FarRed);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		cell_Trans_FarRed_title = "cell_Trans_FarRed"+cell_sub+".tif";
		run("Duplicate...", "title="+cell_Trans_FarRed_title);
		
		selectWindow(Trans_GFP);
		run("RGB Color");
		makeRectangle(cell_x-175, cell_y-175, 350, 350);
		cell_Trans_GFP_title = "cell_Trans_GFP"+cell_sub+".tif";
		run("Duplicate...", "title="+cell_Trans_GFP_title);

		run("Concatenate...", "open image1="+cell_aft_fix_title+" image2="+force_title+" image3="+force_filtered_title+" image4="+disp_title+" image5="+cell_aft_stain_title +" image6="+cell_Trans_DAPI_title+" image7="+cell_Trans_CY5_title+" image8="+cell_Trans_FarRed_title+" image9="+cell_Trans_GFP_title);
		run("Make Montage...", "columns=9 rows=1 scale=1 border=2");
		montage_title = "montage_"+cell_sub+".tif";
		saveAs("Tiff", the_serie_PIV_montage+montage_title);
	}
    run("Close All");

    montages = getFileList(the_serie_PIV_montage);
    for (i=1;i<montages.length+1;i++){
    	if (i < 10) {
			cell_ind = "0" + i; //num of series per well
		}
		else {
			cell_ind = "" + i;
		}
		open(the_serie_PIV_montage+"montage_"+cell_ind+".tif");
    }
    if (n>=2) {
    	run("Images to Stack", "name=Stack title=[] use");
		run("Make Montage...", "columns=1 rows="+montages.length+" scale=1 border=2");
		saveAs("Tiff", the_serie_PIV_montage+"total_montage");
    }
	run("Close All");

}




	

	