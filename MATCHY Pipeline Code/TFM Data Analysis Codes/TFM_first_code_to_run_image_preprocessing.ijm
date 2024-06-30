//created on Mon Jan 3 12:00:34 2022
// @author: Jiageng Liu

function process(file_name, save_path) { //file_name needs to include path; save_path is the location where the files are saved
	print("file name is: "+file_name);
	run("Close All");

	i = 1;
	cur_flag = "0";
	count = 0;
	
	while (count < 500) {
		roiManager("reset");
    	run("Close All");
		run("Clear Results");
		last_flag = parseInt(cur_flag);
		series_name = "series_" + i;
		run("Bio-Formats Importer", "open=" +file_name + " rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT " + series_name);
		title = getTitle();
		print(title);
		cur_flag = parseInt(substring(title, title.length-4, title.length-1)); //for over 100 series 
		//cur_flag = parseInt(substring(title, title.length-3, title.length-1)); //for less than 100 series 
		print(cur_flag);
		split_filename = split(file_name, "/\\");
		
		if (cur_flag < last_flag) {
			print(last_flag);
			close();
			break;
		}
		
		if (i < 10) {
			suffix = "0" + i;
		}
		else {
			suffix = "" + i;
		}
		
		series_folder = save_path + "series_" + suffix;
		if (!File.exists(series_folder)) {
			File.makeDirectory(series_folder);
		}

	
		
		if (startsWith(toUpperCase(split_filename[split_filename.length - 1]), 'W')) {
			selectWindow(title);
			run("Split Channels");
			beads = "C2-"+title;
			cells = "C1-"+title;

			//process cell
			selectWindow(cells);
			run("Find focused slices", "select=100 variance=0.000 edge verbose");
			run("Enhance Contrast", "saturated=0.35");		
			saveAs("Tiff", series_folder + "/" + "cell_before_treatment" + suffix); 
			
			//process beads
			selectWindow(beads);
			//run("Z Project...", "projection=[Max Intensity]");
			run("Find focused slices", "select=100 variance=0.000 edge select_only verbose log");
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", series_folder + "/" + "withcells" + suffix);
		}
		else{
			selectWindow(title);
			run("Split Channels");
			beads = "C2-"+title;
			cells = "C1-"+title;


			//process cell
			selectWindow(cells);
			run("Find focused slices", "select=100 variance=0.000 edge verbose");
			run("Enhance Contrast", "saturated=0.35");	
			saveAs("Tiff", series_folder + "/" + "cell_after_treatment" + suffix);
			
			//process beads
			selectWindow(beads);
			//run("Z Project...", "projection=[Max Intensity]");
			run("Find focused slices", "select=100 variance=0.000 edge select_only verbose log");
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", series_folder + "/" + "reference" + suffix);	
		}
		i++;
		count++; // the number of series in each well
		
	}
	return count;
}


logOutput=1;
input_path = getDirectory("input files");
fileList = getFileList(input_path);
series_num_inWells = newArray();
wells = newArray();
for (i = 0; i < fileList.length; i++) {
	if (!endsWith(fileList[i], '/')) { //if it is not a foler
		save_path = input_path + "well_" + substring(fileList[i], fileList[i].length - 6, fileList[i].length - 4) + '/';
		the_well = "well_" + substring(fileList[i], fileList[i].length - 6, fileList[i].length - 4);
		wells = Array.concat(wells, the_well);
		if (!File.exists(save_path)) {
			File.makeDirectory(save_path);
		}
		print("input_path fileList[i] save_path:");
		print(input_path + " " + fileList[i] + " " + save_path);
		count = process(input_path + fileList[i], save_path);
		series_num_inWells = Array.concat(series_num_inWells,count); 
	}
}
print("wells: ");
Array.print(wells);

for (j=0; j<series_num_inWells.length/2; j++){
	run("Close All");
	suffix = substring(wells[j], wells[j].length - 2, wells[j].length);
	cur_path = input_path +"well_"+suffix; 
	for (k=1; k<=series_num_inWells[j]; k++){
		run("Close All");
		if (k < 10) {
			suffix_sub = "0" + k; //num of series per well
		}
		else {
			suffix_sub = "" + k;
		}
		new_path = cur_path + "/series_"+suffix_sub; 
		ref_processed_beads = new_path +"/reference"+suffix_sub+".tif"; //this is the FULL path for processed reference beads, can open this directly
		withCells_processed_beads = new_path + "/withcells"+suffix_sub+".tif";
		
		//make sure ref is the first image and withcells if the second image in the stack so that "Traction_force_cal" can perform correctly
		print(ref_processed_beads);
		print(withCells_processed_beads);
		open(ref_processed_beads);
		open(withCells_processed_beads);
		run("Images to Stack", "name=well_"+suffix+"_series_"+suffix_sub);
		stacks = input_path+"/well_"+suffix+"/stacks"; //change / before well
		if (!File.exists(stacks)) {
			File.makeDirectory(stacks);
		}
		saveAs("Tiff", stacks+"/well_"+suffix+"_series_"+suffix_sub); //all two-frames tiff stacks are saved in "data/stacks"
		saveAs("Tiff", input_path+"/well_"+suffix+"/series_"+suffix_sub+"/processed beads stack"); //save an extra copy of the stack 
		run("Close All");	

		cell_before_treatment = new_path +"/cell_before_treatment"+suffix_sub+".tif"; 
		cell_after_treatment = new_path + "/cell_after_treatment" + suffix_sub +".tif";
		open(cell_before_treatment);
		open(cell_after_treatment);
		run("Images to Stack", "name=stacked_cells_"+suffix_sub);
		saveAs("Tiff", input_path+"/well_"+suffix+"/series_"+suffix_sub+"/stacked_cells");
		run("Close All");
	}
}
run("Close All");

