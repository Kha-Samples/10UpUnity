let project = new Project('10UpUnity');
project.addSources('Sources');
project.addAssets('Assets/**');
project.addLibrary('Kha2D');
resolve(project);
