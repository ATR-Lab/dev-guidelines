// Deliberately bad C++: scripts/check-configs.sh expects clang-format AND clang-tidy to reject
// this file. Do not copy it. Each comment names the rule that should fire.
#include <string>
#include <vector>

typedef std::vector<double> SpeedList;  // modernize-use-using

class speed_limiter {  // readability-identifier-naming (class), clang-format (brace)
public:
  double MaxSpeed;  // readability-identifier-naming (member)

  double Clamp(double v) {  // readability-identifier-naming (method), clang-format (brace)
    if (v > MaxSpeed) return MaxSpeed;  // readability-braces-around-statements
    return v;
  }

  bool has_name(const std::string name) {  // performance-unnecessary-value-param
    return name.size() == 0 ? false : true;  // readability-container-size-empty
  }
};

int main() {
  int* count = NULL;  // modernize-use-nullptr, clang-format (pointer alignment)
  speed_limiter limiter;
  limiter.MaxSpeed = 1.0;
  return *count;  // clang-analyzer-core.NullDereference
}
