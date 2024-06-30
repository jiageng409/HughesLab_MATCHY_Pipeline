//created on Mon Jan 3 12:00:34 2022
// @author: Jiageng Liu


run("Close All");
logOutput=1;
input_path = getDirectory("input files");
fileList = getFileList(input_path);

for (i = 0; i < fileList.length; i++) {
	if (endsWith(fileList[i], '/')) { 
		if (startsWith(toUpperCase(fileList[i]), 'W')) {
			PIV_folder = input_path + fileList[i]+ "PIV_Force/";
			series_in_the_PIV = getFileList(PIV_folder);
			for (j = 0; j < series_in_the_PIV.length; j++){
				serie_in_PIV = PIV_folder + series_in_the_PIV[j];
				filtered_FTTC = serie_in_PIV + "Traction_aligned_"+ substring(fileList[i], 0, fileList[i].length - 1) +'_'+substring(series_in_the_PIV[j], 0, series_in_the_PIV[j].length - 1)+".tif_PIV3_disp_new.txt";
				run("plot FTTC", "select="+filtered_FTTC+" autoscale vector_scale=1 max=500 plot_width=0 plot_height=0 show draw lut=S_Pet");
				mag_win = "Magnitude map_"+"Traction_aligned_"+ substring(fileList[i], 0, fileList[i].length - 1) +'_'+substring(series_in_the_PIV[j], 0, series_in_the_PIV[j].length - 1)+".tif_PIV3_disp_new.txt";
				selectWindow(mag_win);
				saveAs("Tiff", serie_in_PIV + "/background_subtracted_force_map");
				selectWindow("Scale Graph");
				saveAs("Tiff", serie_in_PIV + "Scale Graph");
				run("Close All");
			}
		}
	}
}

