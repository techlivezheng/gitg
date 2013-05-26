/*
 * This file is part of gitg
 *
 * Copyright (C) 2012 - Jesse van den Kieboom
 *
 * gitg is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gitg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gitg. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GitgExt
{

/**
 * gitg UIElement interface.
 *
 * The GitgExtView interface can be implemented to provide a main view in
 * gitg. An example of such views are the builtin Dashboard, History and
 * Commit views.
 *
 * Implementations of the GitgExtView interface will be integrated
 * automatically in the gitg interface according to the various interface
 * methods and properties that need to be implemented.
 */
public interface UIElement : Object
{
	/**
	 * The main gitg application interface.
	 *
	 * This property is a "construct"
	 * property and will be automatically set when an instance of the ui element
	 * object is created.
	 */
	public abstract GitgExt.Application? application { owned get; construct set; }

	/**
	 * A unique id for the ui element.
	 *
	 * Ids in gitg are normally of the form /org/gnome/gitg/...
	 */
	public abstract string id { owned get; }

	/**
	 * The display name of the ui element.
	 *
	 * This should result in a string which can
	 * be displayed in the gitg UI to identify the element.
	 */
	public abstract string display_name { owned get; }

	/**
	 * The ui element icon.
	 *
	 * If provided, the icon will be used in navigation toolbars
	 * so that users can switch to the ui element.
	 */
	public abstract string? icon { owned get; }

	/**
	 * The ui element widget.
	 *
	 * This widget will be embedded in the gitg UI when
	 * the element is activated.
	 */
	public abstract Gtk.Widget? widget { owned get; }

	/**
	 * Check whether the ui element is available in the current application state.
	 *
	 * This method is used by gitg to verify whether or not a particular ui
	 * element is available given the current state of the application.
	 *
	 */
	public abstract bool available { get; }

	/**
	 * Check whether the ui element is enabled in the current application state.
	 *
	 * This method is used by gitg to verify whether or not a particular ui
	 * element is enabled (sensitive) given the current state of the application.
	 *
	 */
	public abstract bool enabled { get; }

	/**
	 * Negotiate the order with another UIElement.
	 *
	 * This method is used to determine the order in which elements need to
	 * appear in the UI.
	 *
	 * @return -1 if the element should appear before @other, 1 if the
	 *          element should appear after @other and 0 if the order is
	 *          unimportant.
	 *
	 */
	public abstract int negotiate_order(UIElement other);
}

}

// ex: ts=4 noet
