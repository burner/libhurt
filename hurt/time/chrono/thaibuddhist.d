/*******************************************************************************

        copyright:      Copyright (c) 2005 John Chapman. All rights reserved

        license:        BSD style: $(LICENSE)

        version:        Mid 2005: Initial release
                        Apr 2007: reshaped                        

        author:         John Chapman, Kris

******************************************************************************/

module hurt.time.chrono.thaibuddhist;

import hurt.time.chrono.gregorianbased;

/**
 * $(ANCHOR _ThaiBuddhist)
 * Represents the Thai Buddhist calendar.
 */
public class ThaiBuddhist : GregorianBased {
	/**
	 * $(I Property.) Overridden. Retrieves the identifier associated with 
	 * the current calendar.
	 * Returns: An integer representing the identifier of the current calendar.
	 */
	public override const uint id() {
		return THAI;
	}
}
