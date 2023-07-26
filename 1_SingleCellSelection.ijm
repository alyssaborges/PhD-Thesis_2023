/*
 * Macro: Single Cell Selection after Deconvolution
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
 * The purpose of this macro is to facilitate the selection of single cells for further analysis. 
 * It is designed to work with .tif files of single channels (after deconvolution using Huygens Software).
 * 
 * Note: 
 * At this stage, the macro will perform cell selection and save the selected slices, but it does not include additional analysis functionalities.
 * 
 *  
 * Functionalities:
 * 1- automatically open images from separate folders (ensure one folder per channel); 
 * 2- select single cells (regions of interest) for analysis based on DAPI and DIC channels (blind selection for the signal of interest);
 * 3- save selected ROIs (regions of interest);
 * 4- duplicate one slice of the DIC channel and the hyperstack of Far red, Red, Green, and Blue channels;
 * 5- select slices of Far Red, Red, Green, and Blue channels containing in-focus information of the signal of interest;
 * 6- save selected slices as .tif;
 * 
 * 
 * ------------------------- 
 * Instructions:
 * Name your output folder in: "analysisFolderName = [name]".
 * Give a short name to save your images in: "imageShortName = [name]".
 * -------------------------
 * 
 * 
 * For controls: 
 * - Do not select slices (keep all)
 *   
 */
 
 analysisFolderName = "SelectedCells_Analysis";
imageShortName = "Assay1_";


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
		rename(imageShortName+"_"+a+"_");
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
			
				} //attention: this warning happens only once per image
				
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
	
	selectWindow(chB);
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
	dupliFarRed = getTitle();
	
		selectWindow(dupliFarRed);
		saveAs("Tiff", outputDirPath + "C2-" + chA + "_ROI_" + cell);
		close(dupliFarRed);
	
	selectWindow(chC);
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
	dupliRed = getTitle();
	
		selectWindow(dupliRed);
		saveAs("Tiff", outputDirPath + "C3-" + chA + "_ROI_" + cell);
		close(dupliRed);
	
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
		close(dupliGreen);
	
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
		close(dupliBlue);
	
	}
close("*");
}


run("Close All");