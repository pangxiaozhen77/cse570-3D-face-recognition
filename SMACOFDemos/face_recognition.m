% Load the probe. It is sampled with 1000 points.
j = 1; %index of the probe to be used
directory = '../FaceData';
files = dir(fullfile(directory, '*.mat'));
probe = load(fullfile(directory, files(j).name));
probe = remesh(probe.human_face, set_options('vertices', 1000));
probe = init_surface(probe);

% Load the gallery. Each surface in the gallery is sampled with
% 1000 number points.
directory = '../4KMeshWFeaturePoints/4KMesh';
files = dir(fullfile(directory, '*.mat'));

% To test a probe, compute the distortion between the probe
% and each surfaces in the gallery. Find the surface with the lowest
% distortion within a threshold. If a surface is found, the 
% probe belongs to the class of the found surface.

for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face_4k, set_options('vertices', 1000));
    data = init_surface(data);
    [tx, ux, ty, uy, f, rmsdist, maxdist, local_stress] = gmds (data, probe, N);
    distances(i) = rmsdist;  
end

% Print out the distances between the probe and surfaces in the gallery
for i = 1:length(distances)
    fprintf(1, 'RMD distortion between probe %d and %d  = %8.6f\n', j, i, distances(i));   
end

% Questions:
%   - What threshold should be used?
