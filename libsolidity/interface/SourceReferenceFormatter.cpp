/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
 * @author Christian <c@ethdev.com>
 * @date 2014
 * Formatting functions for errors referencing positions and locations in the source.
 */

#include <libsolidity/interface/SourceReferenceFormatter.h>
#include <libsolidity/parsing/Scanner.h>
#include <libsolidity/interface/Exceptions.h>
#include <termcolor.h>

using namespace std;

namespace dev
{
namespace solidity
{

void SourceReferenceFormatter::printSourceLocation(
	SourceLocation const* _location,
	Error::Severity const& _severity
)
{
	if (!_location || !_location->sourceName)
		return; // Nothing we can print here
	auto const& scanner = m_scannerFromSourceName(*_location->sourceName);

	int startLine;
	int startColumn;
	tie(startLine, startColumn) = scanner.translatePositionToLineColumn(_location->start);

	int endLine;
	int endColumn;
	tie(endLine, endColumn) = scanner.translatePositionToLineColumn(_location->end);

	auto color = (_severity == Error::Severity::Warning) ? termcolor::yellow : termcolor::red;

	if (startLine == endLine)
	{
		string line = scanner.lineAtPosition(_location->start);

		int locationLength = endColumn - startColumn;
		if (locationLength > 150)
		{
			line = line.substr(0, startColumn + 35) + " ... " + line.substr(endColumn - 35);
			endColumn = startColumn + 75;
			locationLength = 75;
		}
		if (line.length() > 150)
		{
			line = " ... " + line.substr(startColumn, locationLength) + " ... ";
			startColumn = 5;
			endColumn = startColumn + locationLength;
		}

		m_stream << line.substr(0, startColumn);
		m_stream << color << line.substr(startColumn, locationLength) << termcolor::reset;
		m_stream << line.substr(endColumn) << endl;

		for_each(
			line.cbegin(),
			line.cbegin() + startColumn,
			[this](char const& ch) { m_stream << (ch == '\t' ? '\t' : ' '); }
		);

		m_stream << termcolor::bold << color;
		m_stream << string(locationLength, '^');
		m_stream << termcolor::reset << endl;
	}
	else
		m_stream <<
			scanner.lineAtPosition(_location->start) <<
			endl <<
			string(startColumn, ' ') <<
			"^ (Relevant source part starts here and spans across multiple lines)." <<
			endl;
}

void SourceReferenceFormatter::printSourceName(SourceLocation const* _location)
{
	if (!_location || !_location->sourceName)
		return; // Nothing we can print here
	auto const& scanner = m_scannerFromSourceName(*_location->sourceName);
	int startLine;
	int startColumn;
	tie(startLine, startColumn) = scanner.translatePositionToLineColumn(_location->start);
	m_stream << *_location->sourceName << ":" << (startLine + 1) << ":" << (startColumn + 1) << ": ";
}

void SourceReferenceFormatter::printExceptionInformation(
	Exception const& _exception,
	Error::Severity const& _severity
)
{
	SourceLocation const* location = boost::get_error_info<errinfo_sourceLocation>(_exception);
	auto secondarylocation = boost::get_error_info<errinfo_secondarySourceLocation>(_exception);

	printSourceName(location);

	auto color = (_severity == Error::Severity::Warning) ? termcolor::yellow : termcolor::red;

	m_stream << termcolor::bold << color << severityToString(_severity) << termcolor::reset;
	if (string const* description = boost::get_error_info<errinfo_comment>(_exception))
		m_stream << ": " << *description << endl;
	else
		m_stream << endl;

	printSourceLocation(location, _severity);

	if (secondarylocation && !secondarylocation->infos.empty())
	{
		for (auto info: secondarylocation->infos)
		{
			printSourceName(&info.second);
			m_stream << info.first << endl;
			printSourceLocation(&info.second, _severity);
		}
		m_stream << endl;
	}
}

}
}
