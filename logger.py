
import sys
import coloredlogs, logging
from optparse import OptionParser
coloredlogs.install(level='DEBUG')

if __name__ == '__main__':
  parser = OptionParser()
  parser.add_option("-m", "--mode", dest="mode", default=None,
                    help="Logging mode", metavar="MODE")
  parser.add_option("-x", "--exitcode", dest="exitcode", default=None,
                    help="Command exitcode", metavar="EXITCODE")
  parser.add_option("-i", "--input", dest="input", default='',
                    help="Logging input", metavar="INPUT")
  (options, args) = parser.parse_args(sys.argv[1:])

  exitcode = options.exitcode
  mode = options.mode
  input = options.input

  if mode is None:
    if exitcode is None:
      logging.info(input)
    elif exitcode == '0':
      logging.debug(input)
    else:
      logging.error(input)
  elif mode == 'info':
    logging.info(input)
  elif mode == 'debug':
    logging.debug(input)
  elif mode == 'error':
    logging.error(input)
  elif mode == 'warning':
    logging.warning(input)
  elif mode == 'critical':
    logging.critical(input)
  else:
    logging.info(input)
# python code ends here
