import 'package:instegram/core/usecase/usecase.dart';
import 'package:instegram/data/models/comment.dart';
import 'package:instegram/domain/repositories/post/comment/comment_repository.dart';

class AddCommentUseCase implements UseCase<Comment, Comment> {
  final FirestoreCommentRepository _addCommentRepository;

  AddCommentUseCase(this._addCommentRepository);

  @override
  Future<Comment> call({required Comment params}) {
    return _addCommentRepository.addComment(commentInfo: params);
  }
}
