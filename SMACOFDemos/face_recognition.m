% Load the 4KMesh data set.
directory = '../4KMeshWFeaturePoints/4KMesh';
files = dir(fullfile(directory, '*.mat'));
classRegex = 'human_face\d+';
dataSet = [];
actualClasses = {};
for i = 1:length(files)
    % Skip over human_face4_2_4k.mat because using its
    % remeshed surface causes an error in the gmds function.
    if strcmp(files(i).name, 'human_face4_2_4k.mat')
        continue;
    end
    data = load(fullfile(directory, files(i).name));
    % Remesh is done using 1450 vertices to coincide with the
    % same number of vertices used to remesh the other surfaces
    % from the FaceData set.
    data = remesh(data.human_face_4k, set_options('vertices', 1450));
    data = init_surface(data);
    dataSet = [dataSet data];
    class = regexp(files(i).name, classRegex, 'match', 'once');
    actualClasses{end + 1} = class;
end

% Load the FaceData set.
directory = '../FaceData';
files = dir(fullfile(directory, '*.mat'));
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    % Remesh is done using 1450 vertices because it was found
    % that this number did not produce a single surface from
    % the FaceData set that has an empty cell for the VTRI field
    % With an empty cell in the VTRI field, an error will occur
    % when calling the gmds function.
    data = remesh(data.human_face, set_options('vertices', 1450));
    data = init_surface(data);
    dataSet = [dataSet data];
    class = regexp(files(i).name, classRegex, 'match', 'once');
    actualClasses{end + 1} = class;
end

% Recognition is done by using GMDS to compute the distortion
% between the probe and each surfaces in the gallery and finding
% the surface with the lowest root mean square distortion. The
% probe is identified as the class of the found surface.
%
% Note: It is advised to comment out this block of code below to
% prevent the slow computation of the distance matrix. The distance
% matrix, distance_matrix.mat, can be loaded instead of computed.
gmdsSampleSize = 50;
maxDistortion = 1000000;
for i = 1:length(dataSet)
    for j = 1:length(dataSet)
        % If i == j, the same surface is compared which is guaranteed
        % to have the lowest distortion. The max distortion is stored
        % in the distance matrix when i == j to avoid classifying
        % a surface as itself at a later step.
        if i == j
            distances(i,j) = maxDistortion;
            continue;
        end
        [tx, ux, ty, uy, f, rmsdist, maxdist, local_stress] = gmds (dataSet(i), dataSet(j), gmdsSampleSize);
        distances(i,j) = rmsdist;
    end
end

% Find the lowest distortion and the index of the lowest
% distortion for each probe in the distance matrix. The
% index is used to find the class of the probe.
for i = 1:size(distances, 1)
    lowestDistortion = distances(i,1);
    lowestDistortionIndex = 1;
    for j = 1:size(distances, 2)
        if distances(i,j) < lowestDistortion
            lowestDistortion = distances(i,j);
            lowestDistortionIndex = j;
        end
    end
    predictedClasses{i} = actualClasses{lowestDistortionIndex};
end

% Build the confusion matrix.
uniqueClasses = unique(actualClasses, 'stable');
numUniqueClasses = length(uniqueClasses);
confusionMatrix = zeros(numUniqueClasses);
for i = 1:length(dataSet)
    truthClassIndex = find(ismember(uniqueClasses, actualClasses{i}));
    predictedClassIndex = find(ismember(uniqueClasses, predictedClasses{i}));
    confusionMatrix(truthClassIndex, predictedClassIndex) = confusionMatrix(truthClassIndex, predictedClassIndex) + 1;
end

% Compute the precision rate, recall rate, and F measure.
precision = zeros(1, numUniqueClasses);
recall = zeros(1, numUniqueClasses);
fMeasure = zeros(1, numUniqueClasses);
for i = 1:numUniqueClasses
    precision(i) = confusionMatrix(i,i) / sum(confusionMatrix(:,i));
    recall(i) = confusionMatrix(i,i) / sum(confusionMatrix(i,:));
    fMeasure(i) = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i));
end

% Output distortions
% for i = 1:length(distances)
%      fprintf(1, 'RMD distortion between probe %d and %d  = %8.6f\n', 1, i, distances(i));   
% end
