# import json
# import re

MY_CPU = 0
MY_RAM = 0

class AWSInstance:
  def __init__(self, vCPU, memory, name="custom"):
    self.name = name
    self.vcpu = vCPU
    self.memory = memory

  def __lt__(self, value):
    return self.vcpu < value.vcpu or self.memory < value.memory

  def __gt__(self, value):
    return (self.vcpu >= value.vcpu and self.memory > value.memory) or \
            (self.vcpu > value.vcpu and self.memory >= value.memory)

  def __le__(self, value):
    return self.equivalent(value) or self < value

  def __ge__(self, value):
    return self.equivalent(value) or self > value
  
  def equivalent(self, value):
    return self.vcpu == value.vcpu and self.memory == value.memory

  def __repr__(self):
    return f"<{self.name} ({self.vcpu}, {self.memory})>"


# with open('instances.json') as fh:
#     inst = list(map(lambda i: AWSInstance(**i), json.load(fh)))

instance_list = [
  { "name": "t3.medium", "vCPU": 2, "memory": 4.0 },
  { "name": "t3.xlarge", "vCPU": 4, "memory": 16.0 },
  { "name": "t3.2xlarge", "vCPU": 8, "memory": 32.0 },
  { "name": "t3.small", "vCPU": 2, "memory": 2.0 },
  { "name": "t3.micro", "vCPU": 2, "memory": 1.0 },
  { "name": "t3.large", "vCPU": 2, "memory": 8.0 },
  { "name": "t3.nano", "vCPU": 2, "memory": 0.5 }
]
inst = list(map(lambda i: AWSInstance(**i), instance_list))

def get_sufficient(myCPU, myRAM):
    return min(x for x in inst if x >= AWSInstance(myCPU, myRAM))

print(get_sufficient(MY_CPU, MY_RAM).name)
