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

namespace GitgGtk
{
	public enum CommitModelColumns
	{
		SHA1,
		SUBJECT,
		MESSAGE,
		AUTHOR,
		AUTHOR_NAME,
		AUTHOR_EMAIL,
		AUTHOR_DATE,
		COMMITTER,
		COMMITTER_NAME,
		COMMITTER_EMAIL,
		COMMITTER_DATE,
		COMMIT,
		NUM;

		public Type type()
		{
			switch (this)
			{
				case SHA1:
				case SUBJECT:
				case MESSAGE:
				case COMMITTER:
				case COMMITTER_NAME:
				case COMMITTER_EMAIL:
				case COMMITTER_DATE:
				case AUTHOR:
				case AUTHOR_NAME:
				case AUTHOR_EMAIL:
				case AUTHOR_DATE:
					return typeof(string);
				case COMMIT:
					return typeof(Gitg.Commit);
				default:
				break;
			}

			return Type.INVALID;
		}
	}

	public class CommitModel : Gitg.CommitModel, Gtk.TreeModel
	{
		private uint d_size;
		private int d_stamp;

		public CommitModel(Gitg.Repository? repository)
		{
			Object(repository: repository);
		}

		protected override void emit_started()
		{
			clear();
			base.emit_started();
		}

		private void clear()
		{
			// Remove all
			var path = new Gtk.TreePath.from_indices(d_size);

			while (d_size > 0)
			{
				path.prev();
				--d_size;

				row_deleted(path.copy());
			}

			++d_stamp;
		}

		protected override void emit_update(uint added)
		{
			var path = new Gtk.TreePath.from_indices(d_size);

			Gtk.TreeIter iter = Gtk.TreeIter();
			iter.stamp = d_stamp;

			for (uint i = 0; i < added; ++i)
			{
				iter.user_data = (void *)(ulong)d_size;

				++d_size;

				row_inserted(path.copy(), iter);
				path.next();
			}

			base.emit_update(added);
		}

		public Type get_column_type(int index)
		{
			return ((CommitModelColumns)index).type();
		}

		public Gtk.TreeModelFlags get_flags()
		{
			return Gtk.TreeModelFlags.LIST_ONLY |
			       Gtk.TreeModelFlags.ITERS_PERSIST;
		}

		public bool get_iter(ref Gtk.TreeIter iter, Gtk.TreePath path)
		{
			int[] indices = path.get_indices();

			if (indices.length != 1)
			{
				return false;
			}

			uint index = (uint)indices[0];

			if (index >= d_size)
			{
				return false;
			}

			iter.user_data = (void *)(ulong)index;
			iter.stamp = d_stamp;

			return true;
		}

		public int get_n_columns()
		{
			return CommitModelColumns.NUM;
		}

		public Gtk.TreePath? get_path(Gtk.TreeIter iter)
		{
			uint id = (uint)(ulong)iter.user_data;

			return_val_if_fail(iter.stamp == d_stamp, null);

			return new Gtk.TreePath.from_indices((int)id);
		}

		public void get_value(Gtk.TreeIter iter, int column, ref Value val)
		{
			return_if_fail(iter.stamp == d_stamp);

			uint idx = (uint)(ulong)iter.user_data;
			Gitg.Commit? commit = base[idx];

			val.init(get_column_type(column));

			if (commit == null)
			{
				return;
			}

			switch (column)
			{
				case CommitModelColumns.SHA1:
					val.set_string(commit.get_id().to_string());
				break;
				case CommitModelColumns.SUBJECT:
					val.set_string(commit.get_subject());
				break;
				case CommitModelColumns.MESSAGE:
					val.set_string(commit.get_message());
				break;
				case CommitModelColumns.COMMITTER:
					val.set_string("%s <%s>".printf(commit.get_committer().get_name(),
					                                commit.get_committer().get_email()));
				break;
				case CommitModelColumns.COMMITTER_NAME:
					val.set_string(commit.get_committer().get_name());
				break;
				case CommitModelColumns.COMMITTER_EMAIL:
					val.set_string(commit.get_committer().get_email());
				break;
				case CommitModelColumns.COMMITTER_DATE:
					val.set_string(commit.committer_date_for_display);
				break;
				case CommitModelColumns.AUTHOR:
					val.set_string("%s <%s>".printf(commit.get_author().get_name(),
					                                commit.get_author().get_email()));
				break;
				case CommitModelColumns.AUTHOR_NAME:
					val.set_string(commit.get_author().get_name());
				break;
				case CommitModelColumns.AUTHOR_EMAIL:
					val.set_string(commit.get_author().get_email());
				break;
				case CommitModelColumns.AUTHOR_DATE:
					val.set_string(commit.author_date_for_display);
				break;
				case CommitModelColumns.COMMIT:
					val.set_object(commit);
				break;
			}
		}

		public Gitg.Commit? commit_from_iter(Gtk.TreeIter iter)
		{
			return_val_if_fail(iter.stamp == d_stamp, null);

			uint idx = (uint)(ulong)iter.user_data;

			return base[idx];
		}

		public Gitg.Commit? commit_from_path(Gtk.TreePath path)
		{
			int[] indices = path.get_indices();

			if (indices.length != 1)
			{
				return null;
			}

			return base[(uint)indices[0]];
		}

		public bool iter_children(ref Gtk.TreeIter iter, Gtk.TreeIter? parent)
		{
			if (parent == null)
			{
				iter.user_data = (void *)(ulong)0;
				iter.stamp = d_stamp;

				return true;
			}
			else
			{
				return_val_if_fail(parent.stamp == d_stamp, false);
				return false;
			}
		}

		public bool iter_has_child(Gtk.TreeIter iter)
		{
			return false;
		}

		public int iter_n_children(Gtk.TreeIter? iter)
		{
			if (iter == null)
			{
				return (int)d_size;
			}
			else
			{
				return_val_if_fail(iter.stamp == d_stamp, 0);
				return 0;
			}
		}

		public bool iter_next(ref Gtk.TreeIter iter)
		{
			return_val_if_fail(iter.stamp == d_stamp, false);

			uint index = (uint)(ulong)iter.user_data;
			++index;

			if (index >= d_size)
			{
				return false;
			}
			else
			{
				iter.user_data = (void *)(ulong)index;
				return true;
			}
		}

		public bool iter_nth_child(ref Gtk.TreeIter iter, Gtk.TreeIter? parent, int n)
		{
			if (parent != null || (uint)n >= d_size)
			{
				return false;
			}

			iter.user_data = (void *)(ulong)n;
			iter.stamp = d_stamp;

			return true;
		}

		public bool iter_parent(ref Gtk.TreeIter parent, Gtk.TreeIter iter)
		{
			return_val_if_fail(iter.stamp == d_stamp, false);

			return false;
		}
	}
}

// vi:ts=4
