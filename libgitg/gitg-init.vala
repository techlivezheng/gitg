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

namespace Gitg
{

public errordomain InitError
{
	THREADS_UNSAFE
}

private static bool gitg_inited = false;
private static InitError? gitg_initerr = null;

public void init() throws Error
{
	if (gitg_inited)
	{
		if (gitg_initerr != null)
		{
			throw gitg_initerr;
		}

		return;
	}

	gitg_inited = true;

	if ((Ggit.get_capabilities() & Ggit.CapFlags.THREADS) == 0)
	{
		gitg_initerr = new InitError.THREADS_UNSAFE("no thread support");
	
		warning("libgit2 must be built with threading support in order to run gitg");
		throw gitg_initerr;
	}

	Ggit.init();

	var factory = Ggit.ObjectFactory.get_default();

	factory.register(typeof(Ggit.Repository),
	                 typeof(Gitg.Repository));

	factory.register(typeof(Ggit.Ref),
	                 typeof(Gitg.RefBase));

	factory.register(typeof(Ggit.Branch),
	                 typeof(Gitg.BranchBase));

	factory.register(typeof(Ggit.Commit),
	                 typeof(Gitg.Commit));
}

}

// ex:set ts=4 noet
