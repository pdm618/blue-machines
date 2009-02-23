/***************************************************************************
 *   Copyright (C) 2005 by Yuri Ovcharenko                                 *
 *   amwsoft@gmail.com                                                     *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#ifndef _STDIO_H
#define _STDIO_H

#include <_ansi.h>

#define __need_size_t
#include <stddef.h>

#define __need___va_list
#include <stdarg.h>

#include <sys/types.h>

/*
 * Functions defined in ANSI C standard.
 */

#ifdef __GNUC__
#define __VALIST __gnuc_va_list
#else
#define __VALIST char*
#warning __GNUC__ not defined
#endif

int sprintf(char * buf, const char *fmt, ... );
int snprintf(char *str, size_t size, const char *fmt, ... );
int vsnprintf(char *str, size_t size, const char *fmt, __VALIST args);

#endif
