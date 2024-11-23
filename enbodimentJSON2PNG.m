% Specify the path to your JSON file
jsonFilePath = '/Users/qinchaoyi/Downloads/Chaoyi_male_32_drawings.json';


% Read the JSON file as text
fid = fopen(jsonFilePath, 'r');
if fid == -1
    error('Cannot open JSON file.');
end
raw = fread(fid, inf);
str = char(raw');
fclose(fid);

% Parse the JSON string into a MATLAB structure
data = jsondecode(str);

% Get the list of emotions
emotions = fieldnames(data.drawings);

% Prepare a directory to save images
outputDir = 'Extracted_Images';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Loop through each emotion
for i = 1:length(emotions)
    emotion = emotions{i};
    dataURL = data.drawings.(emotion);
    if ~isempty(dataURL)
        % Remove the data URL prefix
        base64Pattern = 'data:image/png;base64,';
        base64Data = strrep(dataURL, base64Pattern, '');
        
        % Decode the Base64 data
        decodedData = base64decode(base64Data);
        
        % Convert decoded data to an image
        img = imdecode(decodedData);
        
        % Save the image to a file
        outputFileName = sprintf('%s_%s_%s_%s.png', data.name, data.gender, data.age, emotion);
        outputFilePath = fullfile(outputDir, outputFileName);
        imwrite(img, outputFilePath);
        fprintf('Saved image for emotion "%s" to %s\n', emotion, outputFilePath);
    else
        fprintf('No drawing for emotion: %s\n', emotion);
    end
end

% Base64 Decode Function
function bytes = base64decode(str)
    % Remove any whitespace
    str = regexprep(str, '\s', '');
    % Convert string to uint8
    u = uint8(str);
    % Use Java class to decode Base64
    decoder = java.util.Base64.getDecoder();
    bytes = typecast(decoder.decode(u), 'uint8');
end

% Image Decode Function
function img = imdecode(decodedData)
    % Write the decoded data to a temporary file
    tempFile = [tempname '.png'];
    fid = fopen(tempFile, 'w');
    fwrite(fid, decodedData, 'uint8');
    fclose(fid);
    % Read the image from the temporary file
    img = imread(tempFile);
    % Delete the temporary file
    delete(tempFile);
end
