//created on Mon March 14 12:00:34 2022
// @author: Jiageng Liu

run("Close All");
function process(file_name, save_path) { 

	i = 1;
	cur_flag = "0";
	count = 0;
	
	while (count < 1000) {
		roiManager("reset");
    	run("Close All");
		run("Clear Results");
		last_flag = parseInt(cur_flag);
		series_name = "series_" + i;
		run("Bio-Formats Importer", "open=" +file_name + " rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT " + series_name);
		title = getTitle();
		cur_flag = parseInt(substring(title, title.length-3, title.length-1));
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
		
		if (startsWith(toUpperCase(split_filename[split_filename.length - 1]), 'I')) {
			selectWindow(title);
			run("Split Channels");

			BF = "C1-"+title;
			CY5 = "C2-"+title;
			green = "C3-"+title;
			farRed = "C4-" + title;
			DAPI = "C5-"+title;

			selectWindow(BF);
			run("Make Substack...", "  slices=4-6");
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", series_folder + "/" + "cell_after_staining" + suffix);
			cells = getTitle();

			selectWindow(CY5);
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", series_folder + "/" + "CY5" + suffix);
			CY5_new = getTitle();

			selectWindow(green);
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", series_folder + "/" + "GREEN" + suffix);
			GFP = getTitle();

			selectWindow(farRed);
			run("Z Project...", "projection=[Max Intensity]");
			setMinAndMax(0, 900);
			saveAs("Tiff", series_folder + "/" + "FarRed" + suffix);
			RFP = getTitle();

			selectWindow(DAPI);
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", series_folder + "/" + "DAPI" + suffix);
			DAPI_new = getTitle();

			selectWindow(cells);	
			run("8-bit");
			selectWindow(CY5_new);	
			run("8-bit");
			selectWindow(GFP);	
			run("8-bit");
			selectWindow(RFP);	
			run("8-bit");
			selectWindow(DAPI_new);
			run("8-bit");
			run("Merge Channels...", "c1="+RFP + " c2="+GFP+ " c3="+DAPI_new + " c4="+cells +" c6="+CY5_new + " create");
			saveAs("Tiff", series_folder + "/composite_IF" + suffix);
			run("Close All");	
		}	
		i++;
		count++; 	
	}
	return count;
}

logOutput=1;
input_path = getDirectory("input files");
fileList = getFileList(input_path);
series_num_inWells = newArray();

for (i = 0; i < fileList.length; i++) {
	if (!endsWith(fileList[i], '/') && startsWith(toUpperCase(fileList[i]), 'I')) {
		save_path = input_path + "well_" + substring(fileList[i], fileList[i].length - 6, fileList[i].length - 4) + '/';
		if (!File.exists(save_path)) {
			File.makeDirectory(save_path);
		}
		count = process(input_path + fileList[i], save_path);
	}
}