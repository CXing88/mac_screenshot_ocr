use framework "Foundation"
use framework "Vision"
use scripting additions

set gotText to captureImage()

on captureImage()
	set tempFolder to current application's NSTemporaryDirectory()
	set tempImage to tempFolder's stringByAppendingPathComponent:"OCR Temp Image.png"
	set fileManager to current application's NSFileManager's defaultManager()
	
	-- �ù��I�ϨëO�s�����
	do shell script "screencapture -ioxa " & quoted form of (tempImage as text)
	
	try
		set originalText to recognitionText(tempImage)
		(fileManager's removeItemAtPath:tempImage |error|:(missing value))
		
		--�N��r�ǤJ�i�s���ܮ�
		set editedText to displayEditableDialog(originalText)
		
		-- �N���G��J�ŶK�O
		set thePasteboard to current application's NSPasteboard's generalPasteboard()
		thePasteboard's clearContents()
		thePasteboard's setString:editedText forType:(current application's NSPasteboardTypeString)
		
		return editedText
	on error
		display alert "���~" message "�S������r"
		(fileManager's removeItemAtPath:tempImage |error|:(missing value))
		return missing value
	end try
end captureImage

on recognitionText(theImage)
	set theImage to current application's |NSURL|'s fileURLWithPath:theImage
	set requestHandler to current application's VNImageRequestHandler's alloc()'s initWithURL:theImage options:(missing value)
	set theRequest to current application's VNRecognizeTextRequest's alloc()'s init()
	--�]�w���ѻy��
	theRequest's setRecognitionLanguages:{"zh-Hant", "en"}
	theRequest's setUsesLanguageCorrection:false
	requestHandler's performRequests:(current application's NSArray's arrayWithObject:(theRequest)) |error|:(missing value)
	set theResults to theRequest's results()
	set theArray to current application's NSMutableArray's new()
	repeat with aResult in theResults
		(theArray's addObject:(((aResult's topCandidates:1)'s objectAtIndex:0)'s |string|()))
	end repeat
	return (theArray's componentsJoinedByString:linefeed) as text
end recognitionText

-- ��ܱa����J�ت���ܮ�
on displayEditableDialog(defaultText)
	set dialogResult to display dialog "" default answer defaultText buttons {"�T�w"} default button "�T�w" with title "���ѵ��G"
	
	-- ���o�s��᪺�奻
	set editedText to text returned of dialogResult
	return editedText
end displayEditableDialog


