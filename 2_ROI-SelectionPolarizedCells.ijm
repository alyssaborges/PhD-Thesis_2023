/*
 * Macro: Selection of ROI within polarized cells
 * 
 * Copyright (c) 2023 Alyssa Bergmann Borges
 * 
 * ------------------------------------------
 * Permission Notice:
 * I hereby grant permission, free of charge, to any person to use, copy, modify, and merge this macro as long as the original source is cited:
 * Borges, A. (2023). The endo-lysosomal system of Trypanosoma brucei: insights from a protist cell model [Doctoral thesis, Julius-Maximilians-Universität Würzburg].
 * ------------------------------------------
 * 
 * Overview:
 * The purpose of this macro is to select regions of interest within previously selected cells to use in further analysis (e.g., colocalization).
 * This analysis works for polarized cells in which the nucleic acid can be used to identify the region of interest.
 * 
 * Note: 
 * This macro was written to analyze the endosomes of T. brucei (which are polarized in the posterior region of the cell). 
 * It should work to any other polarized structures within regions that can be delimited by DAPI signal.
 * At this stage, the macro will perform ROI selection and save the projections, but it does not include additional analysis functionalities.
 * Use a ROI of 81 x 97 for 2K2N cells
 * 
 *  
 * Functionalities:
 * 1- automatically open images from separate folders (ensure one folder per channel); 
 * 2- select the regions of interest (in cells already selected with macro 1) based on DAPI and DIC channels;
 * 3- save selected ROIs (regions of interest);
 * 4- prepare projections (Sum Slices) and save them as .tif to be used in further analysis.
 * 
 * 
 * ------------------------- 
 * Instructions:
 * Name your output folder in: "analysisFolderName = [name]".
 * -------------------------
 *  
 *   
 */
 
 analysisFolderName = "ROIs_PosteriorRegion";


//-------------- GUI ----------------//
Dialog.create("Analysis Setup");
	Dialog.addDirectory("Input folder", "");
	Dialog.addDirectory("DIC channel folder", "");
	Dialog.addDirectory("Far red channel folder", "");
	Dialog.addDirectory("Red channel folder", "");
	Dialog.addDirectory("Green channel folder", "");
	Dialog.addDirectory("DAPI channel folder", "");
	Dialog.addNumber("Start analysis by image (index)", 0);
Dialog.show();
	userChosenDirectory = Dialog.getString();
	channelA = Dialog.getString();
	channelB = Dialog.getString();
	channelC = Dialog.getString();
	channelD = Dialog.getString();
	channelE = Dialog.getString();
	b = Dialog.getNumber();	
	
	
//-------------- Setting working directory ----------------//
outputDirName = userChosenDirectory + analysisFolderName; //creates a folder to save your analysis
outputDirPath = outputDirName + File.separator; //creates a path to your folder
File.makeDirectory(outputDirName); //creates the output directory


//-------------- Opening images ----------------//
chAList = getFileList(channelA);
chBList = getFileList(channelB);
chCList = getFileList(channelC);
chDList = getFileList(channelD);
chEList = getFileList(channelE);

openingImages();
function openingImages() {
	
	//DIC
	for(a=b; a<chAList.length; a++){
	if(endsWith(chAList[a],".tif")){
		open(channelA + chAList[a]);
		chA = getTitle();
	}
	
	//Far red
	if(endsWith(chBList[a],".tif")){
		open(channelB + chBList[a]);
		chB = getTitle();
	}
	
	//Red
	if(endsWith(chCList[a],".tif")){
		open(channelC + chCList[a]);
		chC = getTitle();
	}
	
	//Green
	if(endsWith(chDList[a],".tif")){
		open(channelD + chDList[a]);
		chD = getTitle();
	}
	
	//DAPI
	if(endsWith(chEList[a],".tif")){
		open(channelE + chEList[a]);
		chE = getTitle();
	}
	
		chooseROI();
	}
}



//-------------- Choosing posterior region ----------------//

function chooseROI() {
	
	selectWindow(chE);
	numberSlices = nSlices;
	if (numberSlices != 1) {
		run("Z Project...", "projection=[Max Intensity]");
	}
	projectionE = getTitle();
	
	run("Merge Channels...", "c4=[" + chA +"] c5=[" + projectionE +"] create");
	temporaryImage = getTitle();
	
	if (isOpen("ROI Manager")) {
     		roiManager("reset");
  				} else {
	run("ROI Manager...");
  				}
  				
	run("Brightness/Contrast...");
	makeRectangle(0, 0, 70, 70);
	waitForUser("Select the posterior region of the cell\nClick OK");
	roiManager("add");
		roiCount = roiManager("count");
		if (roiCount==0) {
		userOption1 = getBoolean("No ROIs added to the manager. Do you want to continue?");
			if (userOption1==false) {
			waitForUser("Select the posterior region of the cell\nClick OK");
			
			}
			
				} //attention: this warning happens only once per image 
				
	saveROI();
	function saveROI() {
		roiCount = roiManager("count");
		if (roiCount > 0) {
			roiManager("save", outputDirPath + "ROI_posterior_" + chA + ".zip");
		}
			 
	}
	
	
	close(chA); close(chE);
	
	selectRegion();
}


//-------------- Preparing single cell projections ----------------//
function selectRegion() {
	
	roiCount = roiManager("count");
	for (i = 0; i < roiCount; i++) {
	
	selectWindow(temporaryImage); //use to filter your data later
	roiManager("Select", i);
	run("Duplicate...", "duplicate"); //duplicate hyperstack
	projection = getTitle();
	
		selectWindow(projection);
		saveAs("Tiff", outputDirPath + "Projection_DAPI-DIC_" + chA + "_posteriorRegion");
		close(projection);
	
	selectWindow(chB);
	roiManager("Select", i);
	run("Duplicate...", "duplicate"); //duplicate hyperstack
	run("Z Project...", "projection=[Sum Slices]");
	dupliFarRed = getTitle();
	
		selectWindow(dupliFarRed);
		saveAs("Tiff", outputDirPath + "Projection_" + chB + "_posteriorRegion");
		close(dupliFarRed);
	
	selectWindow(chC);
	roiManager("Select", i);
	run("Duplicate...", "duplicate"); //duplicate hyperstack
	run("Z Project...", "projection=[Sum Slices]");
	dupliRed = getTitle();
	
		selectWindow(dupliRed);
		saveAs("Tiff", outputDirPath + "Projection_" + chC + "_posteriorRegion");
		close(dupliRed);
	
	selectWindow(chD);
	roiManager("Select", i);
	run("Duplicate...", "duplicate"); //duplicate hyperstack
	run("Z Project...", "projection=[Sum Slices]");
	dupliGreen = getTitle();
	
		selectWindow(dupliGreen);
		saveAs("Tiff", outputDirPath + "Projection_" + chD + "_posteriorRegion");
		close(dupliGreen);
	
	
	}
close("*");
}


run("Close All");