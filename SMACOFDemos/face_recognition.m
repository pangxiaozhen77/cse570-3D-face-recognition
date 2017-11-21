% Load data
dataDirectory = '../FaceData';
files = dir(fullfile(dataDirectory, '*.mat'));
for i = 1:length(files)
    faceDataSet(i) = load(fullfile(dataDirectory, files(i).name));
end
