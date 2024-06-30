//Created on Mon Jan 3 19:38:11 2022
//@author: part of this code is adapted from Martiel et al., Methods in Cell Biology, 2015, ﻿Measurement of cell traction forces with ImageJ,
//to allow for automated, high-throghput analysis with no user input 
  
run("Close All");
logOutput=1;
  
showMessage("<html>"+"<h1><font color=red>Open analysis folder containing the bead images.</h1>"+
" <font color=black>This folder contains:"+
"<ol>"+
"<li> a subfolder 'ParameterData/Parameter.txt'"+
"<li> a set of 2-slices (<font color=red>.tif<font color=black>) stacks (first slice:  without_force, second slice: with_force)."+
"</ol>");

dirAnalysis=getDirectory("Open analysis folder");

listAnalysis=getFileList(dirAnalysis); 

well_in_data = newArray();
for (m = 0; m < listAnalysis.length; m++) {
	if (endsWith(listAnalysis[m], '/')) { 
		well_in_data = Array.concat(well_in_data, listAnalysis[m]);
	}
}

//setBatchMode(true);
for(i=0;i<well_in_data.length;i++){
	if(startsWith(well_in_data[i],"ParameterData")){
		dirP=dirAnalysis+listAnalysis[i];
	}
}


listP=getFileList(dirP);
// get the Parameters.txt index
ParFile=-1;
for (i=0;i<listP.length;i++){
	if (startsWith(listP[i],"Parameters.txt")==true){ParFile=i;}
}

if (ParFile<0){
	showMessage("<html>"+"<big>"+"<font color=red>There is no 'ParameterData' folder and/or 'Parameter.txt' file. Abort macro (press escape button).");
	setKeyDown("Esc");
}

//open parameter file; get information (mechanical parameters; channels parameters)
filestring=File.openAsString(dirP+listP[ParFile]); 
rows=split(filestring, "\n");
ChannelType=newArray();
ChannelName=newArray();
for(i=0; i<rows.length; i++){ 
	locRow=split(rows[i]," \t,;");
	if (locRow[0]=="pixel2um"){pixel2um=parseFloat(locRow[1]);}
	if (locRow[0]=="YoungModulus"){YoungModulus=parseFloat(locRow[1]);}
	if (locRow[0]=="PoissonRatio"){PoissonRatio=parseFloat(locRow[1]);}
	if (locRow[0]=="Regularization"){Regularization=parseFloat(locRow[1]);}
	if (locRow[0]=="vector"){vector=parseFloat(locRow[1]);}
	if (locRow[0]=="max"){max=parseFloat(locRow[1]);}
	if (locRow[0]=="piv1"){piv1=parseFloat(locRow[1]);}
	if (locRow[0]=="sw1"){sw1=parseFloat(locRow[1]);}
	if (locRow[0]=="vs1"){vs1=parseFloat(locRow[1]);}
	if (locRow[0]=="piv2"){piv2=parseFloat(locRow[1]);}
	if (locRow[0]=="sw2"){sw2=parseFloat(locRow[1]);}
	if (locRow[0]=="vs2"){vs2=parseFloat(locRow[1]);}
	if (locRow[0]=="piv3"){piv3=parseFloat(locRow[1]);}
	if (locRow[0]=="sw3"){sw3=parseFloat(locRow[1]);}
	if (locRow[0]=="vs3"){vs3=parseFloat(locRow[1]);}
	
	if (locRow[0]=="channel"){
		ChannelType=Array.concat(ChannelType,locRow[1]);
		ChannelName=Array.concat(ChannelName,locRow[2]);
	}
}

//get channel indexes
channelBead=-1;
for (i=0;i<ChannelType.length;i++){
	kk=-1;kk=indexOf(ChannelType[i],"Bead");if(kk>=0){channelBead=i;}
}
if (channelBead<0){
	showMessage("<html>"+"<big>"+"<font color=red>There is no Bead channel tag. Abort macro.");
	setKeyDown("Esc");
}

if (logOutput==1){
	print("Parameters:");
	print(" \n");
	print("pixel2um is :"+pixel2um);
	print("YoungModulus is :"+YoungModulus);
	print("PoissonRatio is :"+PoissonRatio);
	print("Regularization is :"+Regularization);
	print(" \n");
	print("Channels:");
	for (i=0;i<ChannelName.length;i++){
		print(i+"     "+ChannelType[i]+"  "+ChannelName[i]);
	}
	print("\\======================================================");
}

//===========================================================================

showMessage("<html>"+"<big>"+"<font color=red>Bead alignment.");

first_stack_files = getFileList(dirAnalysis + well_in_data[1] + "stacks/"); 
first_image = dirAnalysis + well_in_data[1] + "stacks/" + first_stack_files[0];
open(first_image);
setMinAndMax(0, 900);
roiManager("reset");
waitForUser("Bead alignment. Please optimise the parameters for running 'Linear Stack Alignment with SIFT'.");
Dialog.create("Parameters for 'Linear Stack Alignment with SIFT'");
Dialog.addNumber("initial_gaussian_blur:",1.60);
Dialog.addNumber("steps_per_scale_octave:", 3);
Dialog.addNumber("minimum_image_size:", 64);
Dialog.addNumber("maximum_image_size:",2048);
Dialog.addNumber("feature_descriptor_size:",4);
Dialog.addNumber("feature_descriptor_orientation_bins:",8);
Dialog.addNumber("closest_next_closest_ratio:", 0.92);
Dialog.addNumber("maximal_alignment_error:", 25);
Dialog.addNumber("inlier_ratio:",0.05);
folder_transformation=newArray();
folder_transformation=Array.concat(folder_transformation,"Translation");
folder_transformation=Array.concat(folder_transformation,"Rigid");
folder_transformation=Array.concat(folder_transformation,"Similarity");
folder_transformation=Array.concat(folder_transformation,"Affine");
Dialog.addChoice("expected_transformation:",folder_transformation);
Dialog.show();
initial_gaussian_blur = Dialog.getNumber();
steps_per_scale_octave = Dialog.getNumber();
minimum_image_size = Dialog.getNumber();
maximum_image_size = Dialog.getNumber();
feature_descriptor_size = Dialog.getNumber();
feature_descriptor_orientation_bins = Dialog.getNumber();
closest_next_closest_ratio = Dialog.getNumber();
maximal_alignment_error = Dialog.getNumber();
inlier_ratio = Dialog.getNumber();
expected_transformation = Dialog.getChoice();

run("Linear Stack Alignment with SIFT", "initial_gaussian_blur="+initial_gaussian_blur+" steps_per_scale_octave="+steps_per_scale_octave+" minimum_image_size="+minimum_image_size+" maximum_image_size="+maximum_image_size+" feature_descriptor_size="+feature_descriptor_size+" feature_descriptor_orientation_bins="+feature_descriptor_orientation_bins+" closest/next_closest_ratio="+closest_next_closest_ratio+" inlier_ratio="+inlier_ratio+" expected_transformation="+expected_transformation);

okAlign = false;
num_attampt = 1;
while (okAlign == false){
	waitForUser("please check alignment");
	okAlign2=getBoolean("Are you happy with this alignment?");
 	if (okAlign2==true){
 		
 		selectWindow("Aligned 2 of 2");
		run("Enhance Contrast", "saturated=0.35");
		saveAs("Tiff",dirP+"/example_of_alignment_"+first_stack_files[0]);
		run("Close All");
		roiManager("reset");
		run("Clear Results");
		print("\\Clear");
		title1="Parameters_for_Alignment";
		title2 = "["+"Parameters_for_Alignment"+"]";
		f=title2;
		if (isOpen(title1)){
			print(f, "\\Update:");
		}else{
			run("Text Window...", "name="+title1+" width=72 height=8 menu");
		}
		selectWindow(title1);
		print(f, "\\Update:");
		print(f,"initial_gaussian_blur "+initial_gaussian_blur+"\n");
		print(f,"steps_per_scale_octave "+steps_per_scale_octave+"\n");
		print(f,"minimum_image_size "+minimum_image_size+"\n");
		print(f,"maximum_image_size "+maximum_image_size+"\n");
		print(f,"feature_descriptor_size "+feature_descriptor_size+"\n");
		print(f,"feature_descriptor_orientation_bins "+feature_descriptor_orientation_bins+"\n");
		print(f,"closest_next_closest_ratio "+closest_next_closest_ratio+"\n");
		print(f,"maximal_alignment_error "+maximal_alignment_error+"\n");
		print(f,"inlier_ratio "+inlier_ratio+"\n");
		print(f,"expected_transformation "+expected_transformation+"\n");
		saveAs("text", dirP+"/"+title1);
		run("Close","title1");
		
		okAlign=true;
		
	}
			
	if (okAlign2==false){
		
		// optimize parameters for "Linear Stack Alignment with SIFT"
		run("Select None");
		waitForUser("Please adjust parameters for 'Linear Stack Alignment with SIFT");
		Dialog.create("Parameters for 'Linear Stack Alignment with SIFT'");
		Dialog.addNumber("initial_gaussian_blur:",1.60);
		Dialog.addNumber("steps_per_scale_octave:", 3);
		Dialog.addNumber("minimum_image_size:", 64);
		Dialog.addNumber("maximum_image_size:",1024);
		Dialog.addNumber("feature_descriptor_size:",4);
		Dialog.addNumber("feature_descriptor_orientation_bins:",8);
		Dialog.addNumber("closest_next_closest_ratio:", 0.92);
		Dialog.addNumber("maximal_alignment_error:", 25);
		Dialog.addNumber("inlier_ratio:",0.05);
		folder_transformation=newArray();
		folder_transformation=Array.concat(folder_transformation,"Translation");
		folder_transformation=Array.concat(folder_transformation,"Rigid");
		folder_transformation=Array.concat(folder_transformation,"Similarity");
		folder_transformation=Array.concat(folder_transformation,"Affine");
		Dialog.addChoice("expected_transformation:",folder_transformation);
		Dialog.show();
		initial_gaussian_blur = Dialog.getNumber();
		steps_per_scale_octave = Dialog.getNumber();
		minimum_image_size = Dialog.getNumber();
		maximum_image_size = Dialog.getNumber();
		feature_descriptor_size = Dialog.getNumber();
		feature_descriptor_orientation_bins = Dialog.getNumber();
		closest_next_closest_ratio = Dialog.getNumber();
		maximal_alignment_error = Dialog.getNumber();
		inlier_ratio = Dialog.getNumber();
		expected_transformation = Dialog.getChoice();
		run("Linear Stack Alignment with SIFT", "initial_gaussian_blur="+initial_gaussian_blur+" steps_per_scale_octave="+steps_per_scale_octave+" minimum_image_size="+minimum_image_size+" maximum_image_size="+maximum_image_size+" feature_descriptor_size="+feature_descriptor_size+" feature_descriptor_orientation_bins="+feature_descriptor_orientation_bins+" closest/next_closest_ratio="+closest_next_closest_ratio+" inlier_ratio="+inlier_ratio+" expected_transformation="+expected_transformation);
	}	
}

run("Close All");




well_path = newArray(); 
for (i=0; i<well_in_data.length; i++){
	if (startsWith(toUpperCase(well_in_data[i]),"W")){
		suffix = substring(well_in_data[i], well_in_data[i].length - 3, well_in_data[i].length-1);
		well_path = Array.concat(well_path, dirAnalysis + well_in_data[i]); 
		stacks_path = dirAnalysis+well_in_data[i]+ "stacks/";
		beads_stacks = getFileList(stacks_path); 
		alignment_path = dirAnalysis + well_in_data[i] + "Aligned_beads/";
		if (File.exists(alignment_path)){} else {File.makeDirectory(alignment_path);}
		PIV_path = dirAnalysis + well_in_data[i] + "PIV_Force/";
		if (File.exists(PIV_path)){} else {File.makeDirectory(PIV_path);}

		for (j=1; j<=beads_stacks.length; j++){ 
			name_of_unaligned_stack = dirAnalysis+well_in_data[i]+"stacks/"+beads_stacks[j-1];
			open(name_of_unaligned_stack);
			setMinAndMax(0, 900);
			run("Linear Stack Alignment with SIFT", "initial_gaussian_blur="+initial_gaussian_blur+" steps_per_scale_octave="+steps_per_scale_octave+" minimum_image_size="+minimum_image_size+" maximum_image_size="+maximum_image_size+" feature_descriptor_size="+feature_descriptor_size+" feature_descriptor_orientation_bins="+feature_descriptor_orientation_bins+" closest/next_closest_ratio="+closest_next_closest_ratio+" inlier_ratio="+inlier_ratio+" expected_transformation="+expected_transformation);
			title = "aligned_"+beads_stacks[j-1]; 
			saveAs("tiff", alignment_path+title);

			if (beads_stacks[j-1].length == 21) {
				suffix_sub = substring(beads_stacks[j-1], beads_stacks[j-1].length - 6, beads_stacks[j-1].length-4);
			}
			else {
				suffix_sub = substring(beads_stacks[j-1], beads_stacks[j-1].length - 7, beads_stacks[j-1].length-4);
			}
			
			PIV_force_each_series_path = PIV_path + "series_" + suffix_sub + "/";
			if (File.exists(PIV_force_each_series_path)){} else {File.makeDirectory(PIV_force_each_series_path);}

			startS=newArray();widthS=newArray();heightS=newArray();
			listTextDisp=newArray();
			listTextForce=newArray();
			
			sparamPIV="piv1="+piv1+" sw1="+sw1+" vs1="+vs1+" piv2="+piv2+" sw2="+sw2+" vs2="+vs2+" piv3="+piv3+" sw3="+sw3+" vs3="+vs3+" correlation=0.99 debug debug_x=-1 debug_y=-1 batch path="+PIV_force_each_series_path+"/";
			selectWindow(title);
			getDimensions(width, height, channels, slices, frames);
			widthS=Array.concat(widthS,width);
			heightS=Array.concat(heightS,height);
			qq=split(beads_stacks[j-1],"_-. ");
			startS=Array.concat(startS,qq[0]);
			run("iterative PIV(Advanced)...",sparamPIV);
			run("Close All");

			textDispFile=title+"_PIV3_disp.txt";
			sparamF="pixel="+pixel2um+" poisson="+PoissonRatio+" young's="+YoungModulus+" regularization="+Regularization+" plot plot="+width+" plot="+height+" select="+PIV_force_each_series_path+"/"+textDispFile+" select="+PIV_force_each_series_path+"/"+textDispFile;
			run("FTTC ",sparamF);
			listTextDisp=Array.concat(listTextDisp,textDispFile);

			textForceFile="Traction_"+textDispFile;
			sparamF="select="+PIV_force_each_series_path+"/"+textForceFile+" select="+PIV_force_each_series_path+"/"+textForceFile +" vector_scale="+vector+" max="+max+" plot_width="+width+" plot_height="+height+" show draw lut=S_Pet";
			run("Close All");
			run("plot FTTC",sparamF);

			ns0=lengthOf(title);
			saveAs("tiff", PIV_force_each_series_path + "ColorBar_"+substring(title,0,ns0-4));
			close();
			saveAs("tiff", PIV_force_each_series_path + "VectorMap_"+substring(title,0,ns0-4));
			close();
			saveAs("tiff", PIV_force_each_series_path + "MagnitudeMap_"+substring(title,0,ns0-4));
			close();
			run("Close All");
			listTextForce=Array.concat(listTextForce,textForceFile);

			// supress useless files in dirPIV
			listPIV = getFileList(PIV_force_each_series_path);
			for (kf=0;kf<listPIV.length;kf++){
				if ((endsWith(listPIV[kf],"_PIV2_disp.txt")==true)){
					File.delete(PIV_force_each_series_path+"/"+listPIV[kf]);
				}
				if ((endsWith(listPIV[kf],"_PIV1_disp.txt")==true)){
					File.delete(PIV_force_each_series_path+"/"+listPIV[kf]);
				}
				if ((endsWith(listPIV[kf],"_PIV2_vPlot.tif")==true)){
					File.delete(PIV_force_each_series_path+"/"+listPIV[kf]);
				}
				if ((endsWith(listPIV[kf],"_PIV1_vPlot.tif")==true)){
					File.delete(PIV_force_each_series_path+"/"+listPIV[kf]);
				}	
				if ((startsWith(listPIV[kf],"FTTCparameters_")==true) && (endsWith(listPIV[kf],"_PIV3_disp.txt")==true)){
					File.delete(PIV_force_each_series_path+"/"+listPIV[kf]);
				}
			}
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// apply mask and calculate actual forces
			wsizeErg=vs3;
			//convert pixel_to_micron into pixel_to_meters
			pixel2m=pixel2um*1e-6;
			// convert the force data into actual forces (in N); factF (m^3/pixel)
			factF=pixel2m*wsizeErg*pixel2m*wsizeErg*pixel2m;
			// convert the window area into meter-square
			factF1=pixel2m*wsizeErg*pixel2m*wsizeErg;
			
			erg=newArray();	
			forceMag=newArray();dispMag=newArray();	
			pascalMag=newArray();
			x_poi=newArray(); y_poi=newArray();
				
			erg0=0;fmag=0;dmag=0;
			disp_file = PIV_force_each_series_path+"aligned_well_"+suffix+"_series_"+suffix_sub+".tif_PIV3_disp.txt";
			force_file = PIV_force_each_series_path+"Traction_aligned_well_"+suffix+"_series_"+suffix_sub+".tif_PIV3_disp.txt";
			filestringD=File.openAsString(disp_file);
			rowD=split(filestringD, "\n");
			filestringF=File.openAsString(force_file);
			rowF=split(filestringF, "\n");

			for (k=0;k<rowD.length;k++){
				rowDD=split(rowD[k]," \t");
				rowFF=split(rowF[k]," \t");
				// J = N x m; rowDD[2] is in pixel			
				ergx=parseFloat(rowDD[2])*parseFloat(rowFF[2])*factF; //factF is in m^3/pixel = m^2 * m/pixel
				// pixel(rowDD[2]) * m/pixel (pixel2m) * Pa (rowFF[3]) * m^2 
				// since m/pixel * m^2 = m^3/pixel = factF
				// pixel(rowDD[2]) * Pa (rowFF[3]) * factF
				ergy=parseFloat(rowDD[3])*parseFloat(rowFF[3])*factF;
				erg0=sqrt(ergx*ergx+ergy*ergy);
				pascalmag = parseFloat(rowFF[4]);
				fmag= pascalmag * factF1;
				dmag=parseFloat(rowDD[4]) * pixel2um; //convert dmag to um, not sure whether rowDD[4] is given in pixel or um, guess pixel makes more sense
				x_poi = Array.concat(x_poi, rowDD[0]); y_poi = Array.concat(y_poi, rowDD[1]);
				erg=Array.concat(erg,erg0);
				forceMag=Array.concat(forceMag,fmag);
				dispMag=Array.concat(dispMag,dmag);
				pascalMag=Array.concat(pascalMag,pascalmag);
			}
			
			// displacement in micro; force in Netwon or Pascal; elastic energy in Joules
			f=File.open(PIV_force_each_series_path+"Energy_forces.txt");
			for (kp=0;kp<erg.length;kp++){
				print(f,kp+"\t "+x_poi[kp]+"\t "+ y_poi[kp]+ "\t "+ erg[kp]+"\t "+forceMag[kp]+"\t "+dispMag[kp]+"\t "+pascalMag[kp]);
			}
			File.close(f);
			
		}		
	}

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
print("done");
selectWindow("Log");
