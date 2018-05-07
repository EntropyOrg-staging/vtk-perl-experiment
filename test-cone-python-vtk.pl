#!/usr/bin/env perl

{ package # hide from PAUSE
vtk;
use AutoLoader;

use Inline Python => <<'END';
import vtk

class vtkProxy(object):
  def __init__(self, target):
    self._target = target

  def __getattr__(self, aname):
    target = self._target
    f = getattr(target, aname)

    def wrap_it(*args):
      u_args_l = []; # final arguments
      for arg in args:
        if isinstance(arg, vtkProxy):
          # unwrap vtkProxy for calling
          arg = arg._target
        u_args_l.append( arg )
      u_args = tuple(u_args_l)

      # proxy the return value
      return vtkProxy(f(*u_args))

    return wrap_it

my_vtk = vtkProxy(vtk)
END

sub AUTOLOAD {
    (my $call = our $AUTOLOAD) =~ s/.*:://;

    # check if syntax is correct
    die "Not a Python identifier: $call" unless( $call =~ /^[^\d\W]\w*\Z/ );

    Inline::Python::py_eval("my_vtk.$call()", 0);
}

}

use Inline Python;

use strict;
use warnings;

method_vtk_manip();

sub method_vtk_manip {
    my $ren = vtk::vtkRenderer();
    my $renWin = vtk::vtkRenderWindow();
    $renWin->AddRenderer($ren);
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
    $coneMapper->SetInputConnection($cone->GetOutputPort());

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

debug = 0

if debug:
  print type(vtk)                        # <type 'module'>
  print type(vtk.vtkRenderer)            # <type 'vtkclass'>
  print type(vtk.vtkRenderer())          # <type 'vtkobject'>
  print getattr(vtk,'vtkRenderer')       # vtkRenderingPython.vtkRenderer
  print type(getattr(vtk,'vtkRenderer')) # <type 'vtkclass'>


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
    coneMapper.SetInputConnection(cone.GetOutputPort())

    # actor
    coneActor = vtk.vtkActor()
    coneActor.SetMapper(coneMapper)

    # assign actor to the renderer
    ren.AddActor(coneActor)

    # enable user interface interactor
    iren.Initialize()
    renWin.Render()
    iren.Start()
