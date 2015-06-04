def sbna2(only_one,one_of_these,data):
  if type(only_one) != list:
    only_one = list(only_one)
  if type(data) != list:
    data = data.split(" ")
  count = 0
  for datoid in only_one:
    if datoid in data and count >= 1:
      return False
    elif datoid in data:
      count += 1
      pass
    else:
      pass
  if count == 0:
    return False
  for datoid in one_of_these:
    if datoid in data:
      return True
  return False
