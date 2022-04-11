abstract class UseCase<R, P> {
  Future<R> call({required P params});
}

abstract class UseCaseTwoParams<R, A, B> {
  Future<R> call({required A paramsOne, required B paramsTwo});
}

abstract class UseCaseThreeParams<R, A, B, C> {
  Future<R> call(
      {required A paramsOne, required B paramsTwo, required C paramsThree});
}

abstract class UseCaseFourParams<R, A, B, C, D> {
  Future<R> call(
      {required A paramsOne,
      required B paramsTwo,
      required C paramsThree,
      required D paramsFour});
}
