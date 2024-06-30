// @author: Jiageng Liu

run("Close All");
logOutput=1;

wellAnalysis = getDirectory("Open well folder");
fileList = getFileList(wellAnalysis);


UE_UE_path = wellAnalysis + "UE_UE/";
UE_UE_chir_7uM_path = UE_UE_path + "chir_7uM/";
UE_UE_300uW_path = UE_UE_path + "300uW/";
UE_UE_negative_path = UE_UE_path + "negative/";

DN_DN_path = wellAnalysis + "DN_DN/";
DN_DN_chir_7uM_path = DN_DN_path + "chir_7uM/";
DN_DN_300uW_path = DN_DN_path + "300uW/";
DN_DN_negative_path = DN_DN_path + "negative/";

UE_DN_path = wellAnalysis + "UE_DN/";
UE_DN_chir_7uM_path = UE_DN_path + "chir_7uM/";
UE_DN_300uW_path = UE_DN_path + "300uW/";
UE_DN_negative_path = UE_DN_path + "negative/";

file_name = wellAnalysis + "well03.nd2"; //you need to manually change this 

function getAngle(x1, y1, x2, y2) {
	q1=0; q2orq3=2; q4=3; //quadrant
	dx = x2-x1;
	dy = y1-y2;
	if (dx!=0)
	  angle = atan(dy/dx);
	else {
	  if (dy>=0)
	      angle = PI/2;
	  else
	      angle = -PI/2;
	}
	angle = (180/PI)*angle;
	if (dx>=0 && dy>=0)
	   quadrant = q1;
	else if (dx<0)
	  quadrant = q2orq3;
	else
	  quadrant = q4;
	if (quadrant==q2orq3)
	  angle = angle+180.0;
	else if (quadrant==q4)
	  angle = angle+360.0;

	angle_quadrant = newArray();
	angle_quadrant = Array.concat(angle_quadrant,angle);
	angle_quadrant = Array.concat(angle_quadrant,quadrant);
	return angle_quadrant;
}


i = 0;
cur_flag = "0";
count = 0;
run("ROI Manager...");

while (count < 1000) {
	
	roiManager("reset");
	run("Close All");
	run("Clear Results");
	last_flag = parseInt(cur_flag);
	series_name = "series_" + i;
	run("Bio-Formats Importer", "open=" +file_name + " rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT " + series_name);
	title = getTitle();
	cur_flag = parseInt(substring(title, title.length-4, title.length-1));
	
	if (cur_flag < last_flag) {
		close();
		break;
	}

	well = substring(file_name, file_name.length - 10, file_name.length - 4);
	if (i < 10) {
		suffix = "00" + i;
	}
	else if (i<100) {
		suffix = "0" + i;
	}
	else {
		suffix = "" + i;
	}

	series_name = well + "_series_" + suffix;

	selectWindow(title);
	run("Split Channels");

	BF = "C1-"+title;
	DN = "C2-"+title;
	UE = "C3-"+title; //you'll have to change these assignments if you are experimenting with different cell types/channels combination 

	selectWindow(BF);
	run("Enhance Contrast", "saturated=0.35");

	selectWindow(DN);
	run("Enhance Contrast", "saturated=0.35");

	selectWindow(UE);
	run("Enhance Contrast", "saturated=0.35");
	
	roiManager("reset");
	setTool("rectangle");
	waitForUser("Please mark points"); 
	
	// you can press shift-a to delete points 
	n = roiManager("count");
	for (k = 0; k < n; k++) {

		roiManager("select", k);
		
		name =split(Roi.getName,"-");
		cur_x = parseFloat(name[1]); cur_y = parseFloat(name[0]);
		cell_sub = k+1;
		
		selectWindow(BF);
		makeRectangle(cur_x-100, cur_y-100, 200, 200);
		doublet_BF = "BF_"+cell_sub+".tif";
		run("Duplicate...", "title="+doublet_BF);
		doublet_BF1 = "BF1_"+cell_sub+".tif";
		run("Duplicate...", "title="+doublet_BF1);
		doublet_BF_composite = "BF_"+cell_sub+"composite.tif";
		run("Duplicate...", "title="+doublet_BF_composite);
		run("8-bit");

		selectWindow(DN);
		makeRectangle(cur_x-100, cur_y-100, 200, 200);
		doublet_green = "Green_"+cell_sub+".tif";
		doublet_green_composite = "Green_"+cell_sub+"composite.tif";
		run("Duplicate...", "title="+doublet_green);
		run("Duplicate...", "title="+doublet_green_composite);
		run("8-bit");
		
		selectWindow(UE);
		makeRectangle(cur_x-100, cur_y-100, 200, 200);
		doublet_red = "Red_"+cell_sub+".tif";
		doublet_red_composite = "Red_"+cell_sub+"composite.tif";
		run("Duplicate...", "title="+doublet_red);
		run("Duplicate...", "title="+doublet_red_composite);
		run("8-bit");
		
		run("Merge Channels...", "c1="+doublet_red_composite + " c2="+doublet_green_composite + " c4="+doublet_BF_composite + " create");
		doublet_composite = getTitle();
		
		selectWindow(doublet_BF);
		run("RGB Color");
		selectWindow(doublet_green);
		run("RGB Color");

		selectWindow(doublet_red);
		run("RGB Color");
		
		selectWindow(doublet_composite);
		run("RGB Color");
		rename("Composite_new");
		new_doublet_composite_title = getTitle();

		run("Concatenate...", "open image1="+doublet_BF+" image2="+doublet_green+" image3="+doublet_red+" image4="+new_doublet_composite_title);
		run("Make Montage...", "columns=4 rows=1 scale=1 border=2");
		doublet_montage = getTitle();
		doublet_montage_title = series_name+"_"+cell_sub+".tif";

		selectWindow(doublet_BF1);
		run("Scale to Fit");
		setTool("line");
		roiManager("Show All");
		waitForUser("please measure contact angle");

		
		n_new = roiManager("count");
		if (n_new>n){
			delete_angle_array = newArray();
			line0 = n_new - 5;
			line1 = n_new - 4;
			line2 = n_new - 3;
			line3 = n_new - 2;
			line4 = n_new - 1;
			delete_angle_array = Array.concat(delete_angle_array,line1);
			delete_angle_array = Array.concat(delete_angle_array,line2);
			delete_angle_array = Array.concat(delete_angle_array,line3);
			delete_angle_array = Array.concat(delete_angle_array,line4);
		
			roiManager("select",line0); 
			getLine(x0_o,y0_o, x0_e, y0_e, lineWidth);
			angle_0 = getAngle(x0_o,y0_o, x0_e, y0_e);
			
			roiManager("select",line1); 
			getLine(x1_o,y1_o, x1_e, y1_e, lineWidth);
			angle_1 = getAngle(x1_o,y1_o, x1_e, y1_e);
	
			roiManager("select",line2); 
			getLine(x2_o,y2_o, x2_e, y2_e, lineWidth);
			angle_2 = getAngle(x2_o,y2_o, x2_e, y2_e);
	
			roiManager("select",line3); 
			getLine(x3_o,y3_o, x3_e, y3_e, lineWidth);
			angle_3 = getAngle(x3_o,y3_o, x3_e, y3_e);
	
			roiManager("select",line4); 
			getLine(x4_o,y4_o, x4_e, y4_e, lineWidth);
			angle_4 = getAngle(x4_o,y4_o, x4_e, y4_e);
			//angle_qua = getAngle(x0_o,y0_o,x0_e,y0_e);
			//angle0 = angle_qua[0]; 
			//quad0 = angle_qua[1];
			
			angle1 = angle_1[0]-angle_0[0];
			if (angle1>180){
				angle1 = angle1 - 360; 
			}
			else if (angle1 < - 180){
				angle1 = angle1+360;
			}
			
			if (angle1>90){
				angle1 = 180-angle1;
			}
			else if (angle1<-90){
				angle1 = angle1+180;
			}
	
			angle2 = angle_2[0]-angle_0[0];
			if (angle2>180){
				angle2 = angle2 - 360; 
			}
			else if (angle2 < - 180){
				angle2 = angle2+360;
			}
			
			if (angle2>90){
				angle2 = 180-angle2;
			}
			else if (angle2<-90){
				angle2 = angle2+180;
			}
			
			angle3 = angle_3[0]-angle_0[0];
			if (angle3>180){
				angle3 = angle3 - 360; 
			}
			else if (angle3 < - 180){
				angle3 = angle3+360;
			}
			
			if (angle3>90){
				angle3 = 180-angle3;
			}
			else if (angle3<-90){
				angle3 = angle3+180;
			}
			
			angle4 = angle_4[0]-angle_0[0];
			if (angle4>180){
				angle4 = angle4 - 360; 
			}
			else if (angle4 < - 180){
				angle4 = angle4+360;
			}
			
			if (angle4>90){
				angle4 = 180-angle4;
			}
			else if (angle4<-90){
				angle4 = angle4+180;
			}
	
			ave_angle = (abs(angle1)+abs(angle2)+abs(angle3)+abs(angle4))/4;
			roiManager("select", delete_angle_array);
			roiManager("delete");
			//print(angle1); print(angle2); print(angle3); print(angle4);
			print(ave_angle);
			Dialog.create("please specify the cell combination & experimental condition");
			cell_combination = newArray();
			cell_combination = Array.concat(cell_combination,"UE_UE");
			cell_combination = Array.concat(cell_combination,"DN_DN");
			cell_combination = Array.concat(cell_combination,"UE_DN");
			Dialog.addChoice("cell-cell type contact:",cell_combination);
	
			exp_condi = newArray();
			exp_condi = Array.concat(exp_condi,"chir_7uM");
			exp_condi = Array.concat(exp_condi,"300uW");
			exp_condi = Array.concat(exp_condi,"negative");
			Dialog.addChoice("experimental condition:",exp_condi);
			Dialog.show();
			cell_cell = Dialog.getChoice();
			the_exp_condition = Dialog.getChoice();
	
			save_path = wellAnalysis + cell_cell + "/" + the_exp_condition + "/";
			selectWindow(doublet_montage);
			saveAs("Tiff", save_path + "montage_" + doublet_montage_title);
			run("Close");
	
			if (cell_cell == "DN_DN"){
				angle_measurements_DN_DN = File.open(save_path+cell_cell+"_angles.txt");
				print(angle_measurements_DN_DN, series_name + "\t " + cell_sub + "\t " + ave_angle);
				File.close(angle_measurements_DN_DN);
				angle_measurements_tempt = File.open(wellAnalysis+"tempt_angles.txt");
				print(angle_measurements_tempt, series_name + "\t " + cell_sub + "\t " + ave_angle);
				File.close(angle_measurements_tempt);		
			}
	
			if (cell_cell == "UE_DN"){
				angle_measurements_UE_DN = File.open(save_path+cell_cell+"_angles.txt");
				print(angle_measurements_UE_DN, series_name + "\t " + cell_sub + "\t " + ave_angle);
				File.close(angle_measurements_UE_DN);
				
				angle_measurements_tempt = File.open(wellAnalysis+"tempt_angles.txt");
				print(angle_measurements_tempt, series_name + "\t " + cell_sub + "\t " + ave_angle);
				File.close(angle_measurements_tempt);
			}
	
			if (cell_cell == "UE_UE"){
				angle_measurements_UE_UE = File.open(save_path+cell_cell+"_angles.txt");
				print(angle_measurements_UE_UE, series_name + "\t " + cell_sub + "\t " + ave_angle);
				File.close(angle_measurements_UE_UE);
				
				angle_measurements_tempt = File.open(wellAnalysis+"tempt_angles.txt");
				print(angle_measurements_tempt, series_name + "\t " + cell_sub + "\t " + ave_angle);
				File.close(angle_measurements_tempt);		
			}
		
			selectWindow(doublet_BF1);
			run("Close");
			selectWindow("Untitled");
			run("Close");
			selectWindow("Composite");'
			run("Close");		
		}	
	}
	i++;
	count++; // the number of series in each well	
}
