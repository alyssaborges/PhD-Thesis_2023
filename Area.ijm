/*
 * Macro: Retrieving area from 2D projections
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
 * The purpose of this macro is to measure the area of binarized images.
 * 
 * 
 *   
 *  
 * Functionalities:
 * 1- automatically open images from separate folders (ensure one folder per channel - ideally have deconvolved images); 
 * 2- select single cells;
 * 3- select slices with in-focus information of the signal of interest, prepare projections (Sum Slices) and apply background subtraction;
 * 4- prepare binary masks (Otsu) and measure with the particle analyzer;
 * 4- save results as .xls. 
 * 
 * 
 * ------------------------- 
 * Instructions:
 * Name your output folder in: "analysisFolderName = [name]".
 * Give a short name to save your images in: "imageShortName = [name]".
 * -------------------------
 *  
 *   
 */
 
analysisFolderName = "SelectedCells_Analysis";
imageShortName = "Assay1_";


//-------------- GUI ----------------//
Dialog.create("Analysis Setup");
	Dialog.addDirectory("Input folder", "");
	Dialog.addDirectory("DIC channel folder", "");
	Dialog.addDirectory("Green channel folder", "");
	Dialog.addDirectory("DAPI channel folder", "");
	Dialog.addNumber("Start analysis by image (index)", 0);
Dialog.show();
	userChosenDirectory = Dialog.getString();
	channelA = Dialog.getString();
	channelD = Dialog.getString();
	channelE = Dialog.getString();
	b = Dialog.getNumber();	
	
//-------------- Setting working directory ----------------//
outputDirName = userChosenDirectory + analysisFolderName; //creates a folder to save your analysis
outputDirPath = outputDirName + File.separator; //creates a path to your folder
File.makeDirectory(outputDirName); //creates the output directory


//-------------- Opening images ----------------//
chAList = getFileList(channelA);
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



//-------------- Choosing single cells ----------------//

function chooseROI() {
	
	run("Merge Channels...", "c4=[" + chA +"] c5=[" + chE +"] create keep");
	temporaryImage = getTitle();
	
	if (isOpen("ROI Manager")) {
     		roiManager("reset");
  				} else {
	run("ROI Manager...");
  				}
  				
	run("Brightness/Contrast...");
	makeRectangle(0, 0, 170, 170);
	waitForUser("Inspect Stack\nSelect ALL your ROIs, add to the ROI manager\nClick OK");
		roiCount = roiManager("count");
		if (roiCount==0) {
		userOption1 = getBoolean("No ROIs added to the manager. Do you want to continue?");
			if (userOption1==false) {
			waitForUser("Inspect Stack\nSelect ALL your cells and add to the ROI manager\nWhen finish, click OK");
			
			}
			
				} //problem: it only repeats the image once 
				
	saveROI();
	function saveROI() {
		roiCount = roiManager("count");
		if (roiCount > 0) {
			roiManager("save", outputDirPath + "ROI_" + chA + ".zip");
		}
			 
	}
	
	selectWindow(temporaryImage);
	close();
	
	selectCells();
}	

//-------------- Preparing single cells stacks ----------------//
function selectCells() {
	
	roiCount = roiManager("count");
	for (i = 0; i < roiCount; i++) {
	
	selectWindow(chA);
	roiManager("Select", i);
	cell = roiManager("index");
	waitForUser("Inspect Stack\nSelect the best focused for this cell, click OK");
	run("Duplicate...", "use");
	dicImage = getTitle();
	
		selectWindow(dicImage);
		saveAs("Tiff", outputDirPath + "C1-" + chA + "_ROI_" + cell);
		close(dicImage);
	
	
	selectWindow(chD);
	roiManager("Select", i);
	cell = roiManager("index");
	run("Duplicate...", "duplicate"); //duplicate hyperstack
	waitForUser("Inspect images and choose slices to keep\n(function applied to all channels)\nClick ok to proceed");
	Dialog.create("Slice Keeper settings");
		Dialog.addNumber("First slice to keep", 1);
		Dialog.addNumber("Last slice to keep", 99);
	Dialog.show();
		first = Dialog.getNumber();
		last = Dialog.getNumber();
	run("Slice Keeper", "first="+first+" last="+last+" increment=1");
	dupliGreen = getTitle();
	
		selectWindow(dupliGreen);
		saveAs("Tiff", outputDirPath + "C4-" + chA + "_ROI_" + cell);
		greenName = getTitle();
		
	
	selectWindow(chE);
	roiManager("Select", i);
	cell = roiManager("index");
	run("Duplicate...", "duplicate"); //duplicate hyperstack
	waitForUser("Inspect images and choose slices to keep\n(function applied to all channels)\nClick ok to proceed");
	Dialog.create("Slice Keeper settings");
		Dialog.addNumber("First slice to keep", 1);
		Dialog.addNumber("Last slice to keep", 99);
	Dialog.show();
		first = Dialog.getNumber();
		last = Dialog.getNumber();
	run("Slice Keeper", "first="+first+" last="+last+" increment=1");
	dupliBlue = getTitle();
	
		selectWindow(dupliBlue);
		saveAs("Tiff", outputDirPath + "C5-" + chA + "_ROI_" + cell);
		blueName = getTitle();
		

	runProjections();	
	}

}


//-------------- Preparing projections ----------------//
function runProjections() {

	selectWindow(greenName);
	run("Z Project...", "projection=[Sum Slices]");
	run("8-bit");
	green = getTitle(); run("In [+]"); run("In [+]");
	run("Duplicate...", "duplicate"); run("In [+]"); run("In [+]");
	dupliGreen = getTitle();
	waitForUser("Action Required", "Please, place images side-by-side");
	selectWindow(dupliGreen);
	run("Convoluted Background Subtraction"); 
	imageGreen = getTitle();

		selectWindow(green);
		saveAs("PNG", outputDirPath + "Projection_" + greenName);
		close(green);
		
		
	selectWindow(blueName);
	run("Z Project...", "projection=[Max Intensity]");
	run("8-bit");
	blue = getTitle(); run("In [+]"); run("In [+]");
		
		selectWindow(blue);
		saveAs("PNG", outputDirPath + "Projection_" + blueName);
		close(blue);	
	
	runMasks();
	
}	


//-------------- Preparing masks ----------------//
function runMasks() { 

	selectWindow(imageGreen);
	setOption("BlackBackground", true);
	run("Auto Threshold", "method=Otsu white");
	maskGreen = getTitle();
	
		
	selectWindow(maskGreen);
	run("Set Scale...", "distance=10.8527 known=1 unit=micron");
	setOption("BlackBackground", true);
	run("Set Measurements...", "area mean min perimeter shape limit display redirect=None decimal=3");
	run("Analyze Particles...", "summarize");
	selectWindow(maskGreen);
	saveAs("PNG", outputDirPath + "Mask_" + greenName);
	close(maskGreen);
	
}
	
//---------------- Saving data --------------------	
Table.save(outputDirPath+"Results.xls","Results" );
close("*");
run("Close All");