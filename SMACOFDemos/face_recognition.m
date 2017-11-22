% Load the gallery. Each surface in the gallery is sampled with
% 1000 points.
directory = '../FaceData';
files = dir(fullfile(directory, '*.mat'));
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face, set_options('vertices', 1000));
    data = init_surface(data);
    gallery(i) = data;
end

% TODO: Compute distortions between each surface in the gallery
% using GMDS and quantize the distortions. Distortions that are
% similar are quantize to a set that represents a class of surfaces.
% To build the set, for each new surface, create a class and add
% all surfaces with distortions that are within a threshold to the
% set. Need to figure out how to determine the threshold. Also,
% move this code to a function.
gmdsSampleSize = 50;

% Load the probes. Each probe is sampled with 1000 points.
directory = '../4KMeshWFeaturePoints/4KMesh';
files = dir(fullfile(directory, '*.mat'));
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face_4k, set_options('vertices', 1000));
    data = init_surface(data);
    probes(i) = data;
end

% TODO: For each probe, compute the distortion between the probe
% and each surface in the gallery and find the surface with the
% lowest distortion. Identify the class that the surface belongs
% and compute the distortions between the probe and each surface
% in the identified class. If the distortions between the probe
% and the other surfaces in the class are within the threshold,
% add the probe to the class. Need to figure out how to determine
% the threshold, and whether all the distortions between the probe
% and other surfaces in the class need to be within a threshold for
% the probe to be identified as the class. Also, move this code to
% a function.