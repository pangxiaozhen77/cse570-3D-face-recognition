% Load the gallery. Each surface in the gallery is reduced
% to 1450 points.
directory = '../FaceData';
files = dir(fullfile(directory, '*.mat'));
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face, set_options('vertices', 1450));
    data = init_surface(data);
    gallery(i) = data;
end

% Load the probes. Each probe is reduced to 1000 points.
directory = '../4KMeshWFeaturePoints/4KMesh';
files = dir(fullfile(directory, '*.mat'));
classRegex = 'human_face\d+';
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face_4k, set_options('vertices', 1000));
    data = init_surface(data);
    probes(i) = data;
    knownClasses{i} = regexp(files(i).name, classRegex, 'match', 'once');
end

% Recognition is done by computing the distortion between
% the probe and each surfaces in the gallery and finding
% the surface with the lowest distortion. The probe is
% identified as the class of the found surface.
gmdsSampleSize = 50;
for i = 1:length(probes)
    for j = 1:length(gallery)
        [tx, ux, ty, uy, f, rmsdist, maxdist, local_stress] = gmds (probes(i), gallery(j), gmdsSampleSize);
        distances(i,j) = rmsdist;
    end
end

% Find the lowest distortion and the index of the lowest
% distortion for each probe. The index is used to find the
% class of the probe.
for i = 1:length(probes)
    lowestDistortion = distances(i,1);
    lowestDistortionIndex = 1;
    for j = 1:length(gallery)
        if distances(i,j) < lowestDistortion
            lowestDistortion = distances(i,j);
            lowestDistortionIndex = j;
        end
    end
    predictedClasses{i} = knownClasses{lowestDistortionIndex};
end

% Build the confusion matrix.
numUniqueClasses = unique(knownClasses);
confusionMatrix = zeros(length(numUniqueClasses));
classRegex = '\d+';
for i = 1:length(predictedClasses)
    truthClass = str2num(regexp(knownClasses{i}, classRegex, 'match', 'once'));
    predictedClass = str2num(regexp(predictedClasses{i}, classRegex, 'match', 'once'));
    confusionMatrix(truthClass, predictedClass) = confusionMatrix(truthClass, predictedClass) + 1;
end

% Compute recall rate, precision rate, and F measure.
recall = 0;
precision = 0;
fMeasure = 0;
for i = 1:length(confusionMatrix(:,1))
end

% Output distortions
% for i = 1:length(distances)
%      fprintf(1, 'RMD distortion between probe %d and %d  = %8.6f\n', 1, i, distances(i));   
% end
