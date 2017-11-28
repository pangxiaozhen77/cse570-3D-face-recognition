% Load the gallery. Each surface in the gallery is sampled with
% 1000 number points.
directory = '../FaceData';
files = dir(fullfile(directory, '*.mat'));
classRegex = 'human_face\d+';
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face, set_options('vertices', 1000));
    data = init_surface(data);
    gallery(i) = data;
    classes{i} = regexp(files(i).name, classRegex, 'match', 'once');
end

% TODO: To build the database, compute distortions between each
% surfaces in the gallery using GMDS and group together surfaces
% with similar distortions. Surfaces with similar distortions
% form a set that represents a class of surfaces.
%
% Questions:
%   - Are the identity of the surfaces known in advance?
%   - What is an appropriate threshold between distortion values
%     to form a group?

% Load the probes. Each probe is sampled with 1000 points.
directory = '../4KMeshWFeaturePoints/4KMesh';
files = dir(fullfile(directory, '*.mat'));
for i = 1:length(files)
    data = load(fullfile(directory, files(i).name));
    data = remesh(data.human_face_4k, set_options('vertices', 1000));
    data = init_surface(data);
    probes(i) = data;
end

% TODO: To test a probe, compute the distortion between the probe
% and each surfaces in the gallery. Find the surface with the lowest
% distortion within a threshold. If a surface is found, the class of
% the found surface is the class of the probe.
%
% Questions:
%   - What threshold should be used?