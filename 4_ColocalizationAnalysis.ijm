/*
 * Macro: Colocalization Analysis in 2D
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
 * The purpose of this macro is to prepare colocalization analysis of two channels based on projections (2D).
 * 
 * 
 * Note: 
 * To use this macro, ensure you already have projections (Sum Slices) prepared and saved as .tif in different folders (one folder per channel).
 * This macro was adapted by Alyssa B. Borges from: 
 * Zhang, C. & Cordelières, F.P. (2016). 3D Quantitative colocalization analysis. In: K. Miura (Ed.), Bioimage Data Analysis (pp. 237-266). Wiley-VCH, Weinheim.
 *  
 *  
 * Functionalities:
 * 1- automatically open images from separate folders (ensure one folder per channel); 
 * 2- select the analysis to be performed: cytofluorogram, Pearson, Spearman, and Manders;
 * 3- retrieve and save intensities as .csv;
 * 4- save plots (cytofluorogram, Pearson, Spearman) as .png and correlation/Manders results as .txt.
 * 
 * 
 * ------------------------- 
 * Instructions:
 * Name your output folder in: "analysisFolderName = [name]".
 * -------------------------
 *  
 *   
 */
 
 setOption("BlackBackground", true);


//-----------Variables--------------//
analysisFolderName = "Coloc_channels_2and3";



var doCytofluorogram=true;
var doPearson=true;
var doSpearman=true;
var doManders=true;


//-------------- GUI ----------------//
Dialog.create("Colocalisation set up");
	Dialog.addDirectory("Input folder", "");
	Dialog.addDirectory("Channel A folder", "");
	Dialog.addDirectory("Channel B folder", "");
	Dialog.addNumber("Start analysis by image (index)", 0);
	Dialog.addCheckbox("Cytofluorogram",true);
	Dialog.addCheckbox("Pearson’s coefficient",true);
	Dialog.addCheckbox("Spearman’s coefficient",true);
	Dialog.addCheckbox("Manders’ coefficients",true);
Dialog.show();
	userChosenDirectory = Dialog.getString();
	channelA = Dialog.getString();
	channelB = Dialog.getString();
	doCytofluorogram=Dialog.getCheckbox();
	doPearson=Dialog.getCheckbox();
	doSpearman=Dialog.getCheckbox();
	doManders=Dialog.getCheckbox();
	b = Dialog.getNumber();	//allows you to chose from which image you want to start your analysis
	

//-------------- Setting working directory ----------------//
outputDirName = userChosenDirectory + analysisFolderName; //creates a folder to save your analysis
outputDirPath = outputDirName + File.separator; //creates a path to your folder
File.makeDirectory(outputDirName); //creates the output directory


//-------------- Opening images ----------------//
chAList = getFileList(channelA)
chBList = getFileList(channelB)

openingImages();
function openingImages() {
	
	//Channel A
	for(a=b; a<chAList.length; a++){
	if(endsWith(chAList[a],".tif")){
		open(channelA + chAList[a]);
		chA = getTitle();
	}
	
	//Channel B
	if(endsWith(chBList[a],".tif")){
		open(channelB + chBList[a]);
		chB = getTitle();
	}
	
	prep2DProjection();
	
	}
}

//-------- Preparing projections ---//

function prep2DProjection(){
	
	selectWindow(chA);
	//run("Z Project...", "projection=[Sum Slices]"); //only run this if you don't have projections
	run("8-bit"); //normalizing 
	projectionA = getTitle();
	
	selectWindow(chB);
	//run("Z Project...", "projection=[Sum Slices]"); //only run this if you don't have projections
	run("8-bit"); //normalizing 
	projectionB = getTitle();
	
	getImageIntensities();
	
}


//--------Retrieve image’s intensities---//

function getImageIntensities(){
	
	selectWindow(projectionA);
	getDimensions(width, height, channels, slices, frames);
	outA=newArray(width*height*slices);
	index=0;

	for(z=1; z<=slices; z++){
		setSlice(z);
		for(y=0; y<height; y++){
			for(x=0; x<width; x++){
				outA[index]=getPixel(x, y);
				index++;
			}
		}
	}

	selectWindow(projectionB);
	getDimensions(width, height, channels, slices, frames);
	outB=newArray(width*height*slices);
	index=0;

	for(z=1; z<=slices; z++){
		setSlice(z);
		for(y=0; y<height; y++){
			for(x=0; x<width; x++){
				outB[index]=getPixel(x, y);
				index++;
			}
		}
	}

		
	
	Array.show("Intensities", outA, outB);
	saveAs("Results", outputDirPath + "Intensities"+projectionA+".csv"); 
	run("Clear Results");
	run("Close");

	if(doCytofluorogram) cytofluorogram();
	if(doPearson) pearson();
	if(doSpearman) spearman();
	if(doManders) manders();
}


//--------Plot cytofluorogram--------//

function cytofluorogram(){
	
	Plot.create("Cytofluorogram", "Channel A", "Channel B", outA, outB);
	Array.getStatistics(outA, xMin, xMax, mean, stdDev); 
	Array.getStatistics(outB, yMin, yMax, mean, stdDev);
	Plot.setLimits(xMin, xMax, yMin, yMax);
	Plot.add("dots", outA, outB);
	Plot.show();
	saveAs("PNG", outputDirPath + "Plot_" + projectionA);

}


//--------Pearson coefficient---------
function pearson(){
	Fit.doFit("y=a*x+b", outA, outB);
	Fit.plot;

	rename("Pearson, Channel A: " + projectionA + ", Channel B: " + projectionB);
	print("------------------");
	print("Pearson’s coefficient: " + Fit.rSquared);
	print("Image 1: " + projectionA);
	print("Image 2: " + projectionB);
	print("Fitting parameters:");
	Fit.logResults;
	saveAs("PNG", outputDirPath + "Pearson_" + projectionA);
}


//--------Spearman coefficient-------//

function spearman(){
	rankedA=Array.rankPositions(outA);
	rankedB=Array.rankPositions(outB);

	Fit.doFit("y=a*x+b", rankedA, rankedB);
	Fit.plot;
	rename("Spearman, Channel A: " + projectionA + ", Channel B: " + projectionB);
	print("------------------");
	print("Spearman’s coefficient: " + Fit.rSquared);
	print("Image 1: " + projectionA);
	print("Image 2: " + projectionB);
	print("Fitting parameters:");
	Fit.logResults;
	saveAs("PNG", outputDirPath + "Spearman_" + projectionA);
}


//--------Manders’ coefficients-------//

function manders(){

	selectWindow(projectionA);
	run("Threshold...");
	setAutoThreshold("Default dark");
	waitForUser("Set the appropriate threshold on " + projectionA + " then click on Ok");
	getThreshold(lowerA, upperA);

	selectWindow(projectionB);
	run("Threshold...");
	setAutoThreshold("Default dark");
	waitForUser("Set the appropriate threshold on " + projectionB + " then click on Ok");
	getThreshold(lowerB, upperB);

	sumA=0;
	sumAColoc=0;

	sumB=0;
	sumBColoc=0;

	for(i=0; i<outA.length; i++){
		if(outA[i]>lowerA) sumA+=outA[i];
		if(outB[i]>lowerB) sumB+=outB[i];

		if(outA[i]>lowerA && outB[i]>lowerB){
			sumAColoc+=outA[i];
			sumBColoc+=outB[i];
		}
	}

	print("------------------");
	print("Mander’s coefficients: ");
	print("Threshold for A: " + lowerA + "; Threshold for channelB : " + lowerB);
	print("M1 (% intensity of A colocalising): " + (sumAColoc*100/sumA));
	print("M2 (% intensity of B colocalising): " + (sumBColoc*100/sumB));
}

string = getInfo("log");
File.saveString(string, outputDirPath + "CorrelationResults.txt");
run("Close");
close("*");