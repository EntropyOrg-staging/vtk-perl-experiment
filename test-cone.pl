#!/usr/bin/env perl

{ package # hide from PAUSE
vtk;
use AutoLoader;

use Inline Python => <<'END';
import vtk
from vtk import vtkXOpenGLRenderWindow
END

sub AUTOLOAD {
    (my $class = our $AUTOLOAD) =~ s/.*:://;
    Inline::Python::py_call_function("vtk", $class);
    #Inline::Python::py_new_object($AUTOLOAD, "vtk", $class);
}

}

use Inline Python;


use strict;
use warnings;

method_vtk_manip();

sub method_vtk_manip {
    my $ren = vtk::vtkRenderer();
    my $renWin = vtk::vtkRenderWindow();
    #$renWin->AddRenderer($ren);
    Inline::Python::py_call_method($renWin, 'AddRenderer', $ren);
    my $WIDTH=640;
    my $HEIGHT=480;
    $renWin->SetSize($WIDTH,$HEIGHT);

    # create a renderwindowinteractor
    my $iren = vtk::vtkRenderWindowInteractor();
    $iren->SetRenderWindow($renWin);

    # create cone
    my $cone = vtk::vtkConeSource();
    $cone->SetResolution(60);
    $cone->SetCenter(-2,0,0);

    # mapper
    my $coneMapper = vtk::vtkPolyDataMapper();
    $coneMapper->SetInput($cone->GetOutput());

    # actor
    my $coneActor = vtk::vtkActor();
    $coneActor->SetMapper($coneMapper);

    # assign actor to the renderer
    $ren->AddActor($coneActor);

    # enable user interface interactor
    $iren->Initialize();
    $renWin->Render();
    $iren->Start();
}

sub method_everything_in_python {
    start();
}

sub study {
    Inline::Python::py_eval('import vtk');
    my %namespace = Inline::Python::py_study_package("vtk");
    use DDP; p %namespace;
}


__END__
__Python__

import vtk
from vtk import vtkRenderer as vtkRenderer

def test():
    return vtk;

def start():
    ren = vtk.vtkRenderer()
    renWin = vtk.vtkRenderWindow()
    renWin.AddRenderer(ren)
    WIDTH=640
    HEIGHT=480
    renWin.SetSize(WIDTH,HEIGHT)

    # create a renderwindowinteractor
    iren = vtk.vtkRenderWindowInteractor()
    iren.SetRenderWindow(renWin)

    # create cone
    cone = vtk.vtkConeSource()
    cone.SetResolution(60)
    cone.SetCenter(-2,0,0)

    # mapper
    coneMapper = vtk.vtkPolyDataMapper()
    coneMapper.SetInput(cone.GetOutput())

    # actor
    coneActor = vtk.vtkActor()
    coneActor.SetMapper(coneMapper)

    # assign actor to the renderer
    ren.AddActor(coneActor)

    # enable user interface interactor
    iren.Initialize()
    renWin.Render()
    iren.Start()
