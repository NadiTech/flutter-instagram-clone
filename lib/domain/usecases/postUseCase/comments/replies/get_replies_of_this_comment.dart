import 'package:instegram/core/usecase/usecase.dart';
import 'package:instegram/data/models/comment.dart';
import 'package:instegram/domain/repositories/post/comment/reply_repository.dart';

class GetRepliesOfThisCommentUseCase
    implements UseCase<List<Comment>, String> {
  final FirestoreReplyRepository _getRepliesOfThisCommentRepository;

  GetRepliesOfThisCommentUseCase(this._getRepliesOfThisCommentRepository);

  @override
  Future<List<Comment>> call({required String params}) async {
    return await _getRepliesOfThisCommentRepository.getSpecificReplies(
      commentId: params,
    );
  }
}
