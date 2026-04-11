unit Dext.Hosting.Events;

interface

type
  { Application Lifecycle Events }

  /// <summary>
  ///   Published after the application host has fully started and is ready to
  ///   accept requests. Handlers may initialise caches, warm-up pools, etc.
  /// </summary>
  TApplicationStartedEvent = record
    Timestamp: TDateTime;
  end;

  /// <summary>
  ///   Published when the application host begins a graceful shutdown.
  ///   Requests may still be in flight. Handlers should start releasing
  ///   resources but avoid blocking for long periods.
  /// </summary>
  TApplicationStoppingEvent = record
    Timestamp: TDateTime;
  end;

  /// <summary>
  ///   Published after all hosted services have stopped and the application is
  ///   about to exit. Use for final clean-up work.
  /// </summary>
  TApplicationStoppedEvent = record
    Timestamp: TDateTime;
  end;

implementation

end.
