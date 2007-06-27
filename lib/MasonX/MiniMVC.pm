package MasonX::MiniMVC;

use warnings;
use strict;

=head1 NAME

MasonX::MiniMVC - Very simple MVC framework for HTML::Mason

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    # in your dhandler
    use MasonX::MiniMVC::Dispatcher;
    my $dispatcher = MasonX::MiniMVC::Dispatcher->new(\%controllers);
    $dispatcher->dispatch($m);

=head1 DESCRIPTION

The problem with Mason is that it's just way too tempting to include
application logic in your components.  It's hard, too, to figure out how
to lay out an application.  What do you put where?  How do you make
something that's not a horrible spaghetti tangle?

MasonX::MiniMVC is something that solves some of these problems for
simple applications.  It provides:

=over 4

=item *

A convention for writing controller classes.

=item *

Views (actually, these are just HTML::Mason components in a known
location).

=item *

A simple Dispatcher class to dispatch requests to appropriate
controllers.

=item *

Some suggestions about how to lay out your application.

=back

It does not provide:

=over 4

=item *

Model classes or conventions -- just use Class::DBI, DBIx::Class, or
whatever else you prefer.  (But we do have a recommended place to put
them.)

=item *

Complex dispatching such as chained or regex dispatching.

=item *

Full support for every Mason behaviour.

=back

=head1 SETTING UP YOUR APPLICATION

=head2 Installation

First, install MasonX::MiniMVC.  I'll assume you've done that.

=head2 Check out the examples

Everything that follows is demonstrated in the examples/library code
provided with the MasonX::MiniMVC distribution. 

=head2 Application structure

Next, go to wherever you want to set up your web application and set up
a directory structure that looks something like this:

    lib/
        AppName/ 
            Controller/
            Model/
    t/
    view/

The purpose of these is as follows:

=over 4

=item lib

Library directory for your application.

=item lib/AppName

All your application logic lives in here.  From an MVC point of view,
this directory contains your Models and Controllers.

=item lib/AppName/Controller

Your controllers will live under this directory, one Perl module per
controller.

=item lib/AppName/Model

Your data access and related logic will live here.  Use Class::DBI,
DBIx::Class, or whatever suits you.

=item t

This directory contains automated tests for the libraries in lib/

=item view/

This is where you store Mason components used as top-level page views in
your web app.  You can also include sub-components here in whatever way
suits you.

=back

=head2 Configuring Apache and/or Mason

=over 4

=item *

Set your DocumentRoot to the web/ directory you just created.

=item *

Set your ComponentRoot to the views/ directory.

=item *

Make sure your Mason setup allows you to use the libraries in lib/.

=item *

Make sure you have Mason handling everything in the directory, not just
*.mhtml files.  You may need to "SetHandler mason-handler" or similar in
your Apache config.

=back

=head2 Create an autohandler

You'll probably want an autohandler to provide the overall look and feel
for your site.  Here's a basic one:

    <html>
    <head>
    <title>My Site</title>
    </head>
    <body>

    % $m->call_next();

    </body>
    </html>

    <%init>
    </%init>

=head2 Create a dhandler

You will definitely need a dhandler.  This is what dispatches things to
the various controllers.  You'll want it to look something like this:

    <%init>
    use MasonX::MiniMVC::Dispatcher;

    my $dispatcher = MasonX::MiniMVC::Dispatcher->new({
        'author'              => 'Library::Controller::Author',
        'book'                => 'Library::Controller::Book',
        'book/recommendation' => 'Library::Controller::Book::Recommendation',
    });

    $dispatcher->dispatch($m);
    </%init>

Note that the dispatcher will pick the best (i.e. deepest) possible
match from among the controllers you specify.  Order is unimportant.

=head2 Create an index.mhtml front page

The dhandler can't handle the very front page of your site, so you need
to have an index.mhtml file in there.

=head2 Create controller classes

In the example given above, you'll want to create classes for
Library::Book, Library::Book::Recommendation, and Library::Author.  Each of
these B<must> contain the following methods:

=over 4

=item default()

The default action to take for any given controller, to be shown when
someone goes to http://example.com/book/ or http://example.com/author/

=back

Other controllers will correspond with part of the URL.  For instance,
using the example above, a URL like http://example.com/book/search would
call Library::Controller::Book::search().

A truly minimal controller method will look like this:

    sub search {
        my ($self, $m, @args) = @_;
        $m->comp("views/book/search.mhtml");
    }

If the URL appears deeper, eg. http://example.com/book/view/12345, then
Library::Controller::Book::view() is called and "12345" is passed in as part of the
parameters.  To put it another way: the dispatcher will find the deepest
possible match available, strip off the matched part, and turn any
further parts of dhandler_arg into a list of args for the controller
method.

Here's an example view() method for http://example.com/book/view/12345:

    sub view {
        my ($self, $m, $book_id) = @_;
        my $book = Library::Model::Book->fetch($book_id);
        $m->comp("views/book/view.mhtml", book => $book);
    }

=head2 Prevent access to sensitive directories

You probably want to use .htaccess to prevent people getting at lib/,
t/, view/, and the autohandler and dhandler from the browser.

=head1 THESE THINGS DO NOT WORK

The following are unimplemented or simply known not to work.

=head2 autohandlers below the top level

You get one top-level autohandler for your app.  You can't have any
below that.

=head2 404s

I've got it doing a $m->clear_and_abort(404) if it can't find a
controller for a URL, but it doesn't work for me under
HTML::Mason::CGIHandler.  Help wanted!

=head1 AUTHOR

Kirrily "Skud" Robert, C<< <skud at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-masonx-minimvc at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MasonX-MiniMVC>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MasonX::MiniMVC

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MasonX-MiniMVC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MasonX-MiniMVC>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MasonX-MiniMVC>

=item * Search CPAN

L<http://search.cpan.org/dist/MasonX-MiniMVC>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Kirrily "Skud" Robert, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of MasonX::MiniMVC
